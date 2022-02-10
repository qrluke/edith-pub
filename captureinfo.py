import datetime
import io
import json as js
import os
import time

import dico
import pytz
import yaml

from utils import ctime


def captureinfo(textdraw, bikers, capture, capture_next):
    class MyDumper(yaml.Dumper):
        def increase_indent(self, flow=False, indentless=False):
            return super(MyDumper, self).increase_indent(flow, False)

    def getDateMoscow(unix):
        return datetime.datetime.utcfromtimestamp(unix).astimezone(pytz.timezone("Europe/Moscow")).strftime(
            "%Y-%m-%d %H:%M:%S")

    class capt:
        def __init__(self, api, channel, started, reason):
            self.api = api
            self.time = time.time()
            self.chn = channel
            self.str = "ПОДНЯТЬ ЩИТЫ "
            self.ids = ["LV", "SF", "LS", "NEW SF", "xz"]
            self.started = started
            self.started_reason = reason

            with io.open('config/discord.json') as file:
                twinkss = js.loads(file.read())

            for k, id in twinkss.items():
                self.str = self.str + f"<@{id}> "
            self.pred = self.str
            self.msg = int(api.create_message(self.chn, content=self.str).id)
            self.pred_bikers = {}
            self.update()

        def genCaptureYaml(self, bikers):
            foo = {
                "id": self.ids[textdraw["capture_id"]],
                "timing": time.time(),
                "explain": {
                    "started": getDateMoscow(self.started),
                    "reason": self.started_reason,
                },
                "status": {
                    "status": getStatus(),
                    "timing": "?",
                    "end": "?",
                },
                "players": {
                    "attackers": {
                        "count": 0,
                        "name": textdraw["attacker"],
                        "kills": textdraw["attacker_kills"],
                        "list": []
                    },
                    "defenders": {
                        "count": 0,
                        "name": textdraw["defender"],
                        "kills": textdraw["defender_kills"],
                        "list": []
                    }
                }
            }

            if "type" in capture:
                foo["status"]["timing"] = str(
                    datetime.timedelta(seconds=int(capture["time"] + capture["type"] * 60 + 5 - time.time())))
                foo["status"]["end"] = getDateMoscow(capture["time"] + capture["type"] * 60 + 5)

            if getStatus() == "active_textdraw":
                foo["status"]["timing"] = "~~~" + str(
                    datetime.timedelta(seconds=int(textdraw["timestamp_cr"] + 25 * 60 - time.time())))
                foo["status"]["end"] = '~~~' + getDateMoscow(textdraw["timestamp_cr"] + 25 * 60)

            if getStatus() == "end" or getStatus() == "unknown":
                del foo["status"]["timing"]

                if "type" in capture and capture["time"] + 300 > ctime():
                    if capture["type"] == -1:
                        foo["status"]["status"] = "WIN"

                    elif capture["type"] == -2:
                        foo["status"]["status"] = "LOSE"

            for key in bikers.keys():
                for index in sorted(list(dict(bikers[key]).keys()), key=lambda x: int(x)):
                    foo["players"][key]["list"].append(bikers[key][index])
                foo["players"][key]["count"] = len(foo["players"][key]["list"])

            return f"```yaml\n{yaml.dump(foo, Dumper=MyDumper, sort_keys=False)}```"

        def update(self):
            if getStatus() == "active" or getStatus() == "active_textdraw":
                to_send = self.genCaptureYaml(bikers)
                if self.str != to_send:
                    self.str = to_send
                    api.edit_message(self.chn, self.msg, content=self.pred + "\n" + self.str)
                self.pred_bikers = bikers.copy()
            else:
                time.sleep(1)
                api.edit_message(self.chn, self.msg, content=self.genCaptureYaml(self.pred_bikers))
                time.sleep(1)
                if "type" in capture and capture["time"] + 300 > ctime():
                    if capture["type"] == -1:
                        api.create_reaction(self.chn, self.msg, "😎")
                    elif capture["type"] == -2:
                        api.create_reaction(self.chn, self.msg, "😡")
                    else:
                        api.create_reaction(self.chn, self.msg, "❓")
                else:
                    api.create_reaction(self.chn, self.msg, "❓")

                if capture_next["next"] < ctime():
                    capture_next["next"] = ctime() + 7200
                    capture_next["timestamp"] = ctime()

    def getStatus():
        if "type" in capture:
            if capture["type"] <= 0:
                if ctime() - capture["time"] > 3600:
                    if textdraw["timestamp_cr"] != -1:
                        if textdraw["timestamp_cr"] + 25 * 60 + 25 > ctime():
                            return "active_textdraw"
                        else:
                            return "unknown"
                    else:
                        return "end"
                return "end"
            if capture["time"] + capture["type"] * 60 + 25 > ctime():
                return "active"
            else:
                if ctime() - capture["time"] > 3600:
                    if textdraw["timestamp_cr"] != -1:
                        if textdraw["timestamp_cr"] + 25 * 60 + 25 > ctime():
                            return "active_textdraw"
                        else:
                            return "unknown"
                    else:
                        return "end"
                else:
                    return "unknown"
        else:
            if textdraw["timestamp_cr"] != -1:
                if textdraw["timestamp_cr"] + 25 * 60 + 25 > ctime():
                    return "active_textdraw"
                else:
                    return "unknown"
            return "unknown"

    api = dico.APIClient(os.environ["discord"], base=dico.HTTPRequest)
    cur_capt = None
    while True:
        if 'cur_capt' in locals() and cur_capt:
            cur_capt.update()
            if getStatus() == "end" or getStatus() == "unknown":
                cur_capt.update()
                del cur_capt
                textdraw["attacker"] = "?"
                textdraw["attacker_kills"] = -1
                textdraw["defender"] = "?"
                textdraw["defender_kills"] = -1
                textdraw["capture_id"] = -1
                textdraw["timestamp_cr"] = -1
        else:
            if getStatus() == "active":
                cur_capt = capt(api, os.environ["capture_channel"], capture["time"], str(capture["type"]))
            elif getStatus() == "active_textdraw":
                cur_capt = capt(api, os.environ["capture_channel"], ctime(), "textdraw with kills / no timing")

        time.sleep(5)
