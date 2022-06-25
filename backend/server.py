#!/usr/bin/env python3
import asyncio
import io
import json as js
import os
import re
import sys
import threading
import time
import urllib.parse

from databases import Database
from sanic import Sanic
from sanic.exceptions import NotFound
from sanic.response import json

from utils import ctime, startup_check

try:
    sys.argv[1]
    int(sys.argv[1])
except IndexError:
    print("usage: python3 server3.py [DELAY (MS)]")
    sys.exit(0)

DELAY = int(sys.argv[1])

if str(os.environ["enable_sentry"]) == "1":
    import sentry_sdk
    from sentry_sdk.integrations.sanic import SanicIntegration

    sentry_sdk.init(
       dsn=str(os.environ["sentry_dsn"]),
       integrations=[SanicIntegration()]
    )


app = Sanic(name='edith-server')

twinks = {"data": {}}

last_changed = 0

users = {}


def process_auth(info):
    global last_changed

    if last_changed != os.stat("config/whitelist.txt").st_mtime:
        with io.open('config/whitelist.txt') as file:
            for line in file:
                x = line.split()
                if len(x) == 2:
                    users.update({x[0]: x[1]})
        last_changed = os.stat("config/whitelist.txt").st_mtime

    if info['auth'] not in users:
        return {"result": "wrong user"}
    else:
        if info['password'] == users[info['auth']]:
            return {"result": "ok", "like": list(users.keys()), "delay": DELAY}
        else:
            return {"result": "wrong password", "delay": DELAY}


last_c = time.time()

nicks = {}


def clear_old():
    global last_c

    if time.time() - last_c > 300:
        last_c = time.time()
        del_nicks_list = []
        for k, v in nicks.items():
            if time.time() - v["timestamp"] > 300:
                del_nicks_list.append(k)
        for k in del_nicks_list:
            if k in nicks:
                del nicks[k]


bikers = {"data": {}}
admins_afk = {"timestamp": 0, "data": {}}


def process_bikers(info):
    global bikers

    if "bikers" in info["data"]:
        bikers["data"] = info["data"]["bikers"]

def process_admins(info, answer):
    global admins_afk

    if "admins" in info["data"]:
        admins_afk["timestamp"] = ctime()
        admins_afk["data"] = info["data"]["admins"]["data"]

    if "requestAdminsAfk" in info["data"]:
        answer["admins"] = admins_afk


def process_glonass(info, answer):
    if 'sender' in info["data"]:
        nicks.update({info["data"]['sender']['sender']: {
            'timestamp': time.time(),
            'heading': info["data"]['sender']['heading'],
            'health': info["data"]['sender']['health'],
            'x': info["data"]['sender']['pos']['x'],
            'y': info["data"]['sender']['pos']['y'],
            'z': info["data"]['sender']['pos']['z'],
        }})

    if info["data"]['request'] == 1:
        answer["nicks"] = nicks


last_cl = time.time()

capters = {}
capterslist = []


def process_acapture(info, answer):
    global last_cl

    if 'capter' in info["data"]:
        capter = info["data"]["capter"]
        if time.time() - last_cl > 15:
            last_cl = time.time()
            del_capters_list = []
            for k in capters.keys():
                if time.time() - capters[k]["lastseen"] > 15:
                    del_capters_list.append(k)
            for k in del_capters_list:
                if k in capters:
                    del capters[k]
                    print(k + "deleted")
                if k in capterslist:
                    capterslist.remove(k)
                    print(k + "deleted")
        if info["data"]["type"] == "register":
            if capter in capters:
                del capters[capter]
            if capter in capterslist:
                capterslist.remove(capter)
            capters[capter] = {'lastcapt': 0, 'lastseen': time.time()}
            capterslist.append(capter)
            answer["capter"] = "Go capture! " + str(len(capters))
        if info["data"]["type"] == "ready":
            if capters[capter] == None:
                capters[capter] = {'lastcapt': 0, 'lastseen': time.time()}
            capters[capter]['lastseen'] = time.time()
            ind = capterslist.index(capter)
            if ind <= 5:
                if int(time.time()) % 5 == ind and time.time() - capters[capter]["lastcapt"] > 4:
                    capters[capter]["lastcapt"] = time.time()
                    answer["capter"] = "GO"
                else:
                    answer["capter"] = "WAIT"
            else:
                if int(time.time() + 0.5) % 5 == ind % 5 and time.time() - capters[capter]["lastcapt"] > 4:
                    capters[capter]["lastcapt"] = time.time()
                    answer["capter"] = "GO"
                else:
                    answer["capter"] = "WAIT"
        if info["data"]["type"] == "unregister":
            if capter in capters:
                del capters[capter]
            if capter in capterslist:
                capterslist.remove(capter)
            answer["capter"] = "END"


death_list = []

skins_army = [287, 191]
skins_gos = [165, 166, 280, 281, 282, 283, 284, 285, 286, 288, 300, 301, 302, 303, 304, 305, 306, 307, 309, 310, 311,
             163, 164]
skins_ghetto = [114, 115, 116, 292, 41, 173, 174, 175, 226, 273, 105, 106, 107, 56, 269, 270, 271, 102, 103, 104, 195,
                108, 109, 110, 190]
skins_bikers = [247, 248, 254, 100, 181, 178, 246]

admins = ["Nick_Name"]


async def process_deathlist(info, answer):
    if "deathList" in info["data"]:
        for i in info["data"]["deathList"]:
            if len(death_list) == 5:
                death_list.pop(0)
            if i["type"] == "died":
                score = 0
                if 'killerNick' in i:
                    text = f"DIED: {i['killerNick']} ubil {i['killedNick']} iz {i['weapon']}"
                else:
                    text = f"{i['killedNick']} ubil sebya"
            elif i["type"] == "afk":
                score = 0.5
                if i["killedNick"] in users:
                    score = -1
                if i["killedNick"] in admins:
                    score = -10
                text = f"KILL V AFK: {i['killerNick']} ubil {i['killedNick']} iz {i['weapon']}, zas4itano {score} o4kov."
            elif i["type"] == "normal":
                if i['skin'] in skins_army:
                    score = 3
                elif i['skin'] in skins_ghetto:
                    score = 2
                elif i['skin'] in skins_gos:
                    score = 5
                elif i['skin'] in skins_bikers:
                    score = 2
                else:
                    score = 1

                if i["killedNick"] in users:
                    score = -1
                if i["killedNick"] in admins:
                    score = -10
                if i["lvl"] < 4 and i["lvl"] > 0:
                    score = score * 2
                text = f"4estniy kill: {i['killerNick']} ubil {i['killedNick']} iz {i['weapon']}, zas4itano {score} o4kov."
            elif i["type"] == "dm":
                score = 5
                text = f"DM: {i['killerNick']} posadil {i['killedNick']} na {i['lvl']}: {i['weapon']}."

            death_list.append({"time": time.time(), "data": i, "text": text, "score": score})

            query = "INSERT INTO kills(timestamp, killer, killed, weapon, skin, lvl, type, score) VALUES (:timestamp, :killer, :killed, :weapon, :skin, :lvl, :type, :score)"
            killer = "nil"
            if "killerNick" in i:
                killer = i["killerNick"]

            values = {
                "timestamp": ctime(),
                "killer": killer,
                "killed": i["killedNick"],
                "weapon": i["weapon"],
                "skin": i["skin"],
                "lvl": i["lvl"],
                "type": i["type"],
                "score": score
            }

            await database.execute(query=query, values=values)

    if "dmg_in" in info["data"]:
        query = "INSERT INTO dmg_in(timestamp, nick, damage) VALUES (:timestamp, :nick, :damage)"
        values = {
            "timestamp": ctime(),
            "nick": info['creds']['nick'],
            "damage": info["data"]["dmg_in"]
        }

        await database.execute(query=query, values=values)

    if "dmg_out" in info["data"]:
        query = "INSERT INTO dmg_out(timestamp, nick, damage) VALUES (:timestamp, :nick, :damage)"
        values = {
            "timestamp": ctime(),
            "nick": info['creds']['nick'],
            "damage": info["data"]["dmg_out"]
        }

        await database.execute(query=query, values=values)

    if "getDeathList" in info["data"]:
        answer["deathList"] = death_list


bikers_textdraw = r"~y~KILLS~n~ ~n~~r~(.+): ~w~(\d+)~n~~b~(.+): ~w~(\d+)~n~~b~~h~ID\((\d)\)"

textdraw = {}
textdraw["timestamp_cr"] = -1
textdraw["attacker"] = "?"
textdraw["attacker_kills"] = -1
textdraw["defender"] = "?"
textdraw["defender_kills"] = -1
textdraw["capture_id"] = -1

capture = {}


def process_capturetimer(info, answer):
    if "timeleft_type" in info["data"]:
        if "time" not in capture:
            capture["time"] = time.time()
            capture["type"] = info["data"]["timeleft_type"]
        else:
            if capture["type"] == info["data"]["timeleft_type"]:
                if capture["type"] == 25:
                    if time.time() - capture["time"] > 3600:
                        capture["time"] = time.time()
                elif capture["type"] == 10:
                    if time.time() - capture["time"] > 3600:
                        capture["time"] = time.time()
                elif capture["type"] == 2:
                    if time.time() - capture["time"] > 100:
                        capture["time"] = time.time()
                elif capture["type"] == 0:
                    if time.time() - capture["time"] > 3600:
                        capture["time"] = time.time()
            else:
                if time.time() - capture["time"] > 60:
                    capture["time"] = time.time()
                    capture["type"] = info["data"]["timeleft_type"]

    if "textdraw" in info["data"]:
        if info["data"]["textdraw"]["text"].find(os.environ["curb"]) != -1:
            td = re.match(bikers_textdraw, info["data"]["textdraw"]["text"])
            if textdraw["timestamp_cr"] == -1:
                textdraw["timestamp_cr"] = ctime()
            textdraw["attacker"] = td[1]
            textdraw["attacker_kills"] = int(td[2])
            textdraw["defender"] = td[3]
            textdraw["defender_kills"] = int(td[4])
            textdraw["capture_id"] = int(td[5])

    answer["capture"] = capture.copy()

    if "type" in answer["capture"]:
        if answer["capture"]["type"] <= 0:
            answer["capture"]["type"] = 0


warehouse = {"timestamp": 0, "warehouse": 0, "max": 200000}
warehouse_rest = {"timestamp": 0, "heal": 0, "heal_max": 5000, "alk": 0, "alk_all": 0, "benz": 0, "benz_all": 0}
capture_data = {"timestamp": 0, "f0": {"t": "w", "c": "mc"}, "f1": {"t": "w", "c": "mc"}, "f2": {"t": "w", "c": "mc"},
                "f3": {"t": "w", "c": "mc"}, "f4": {"t": "w", "c": "mc"}, "s0": {"t": "w", "c": "mc"},
                "s1": {"t": "w", "c": "mc"}, "s2": {"t": "w", "c": "mc"}}
capture_next = {"timestamp": 0, "next": 0}


def process_bikerinfo(info):
    if 'bikerinfo' in info["data"]:
        short = info["data"]["bikerinfo"]
        if "warehouse_simple" in short:
            warehouse.update({"timestamp": ctime(), "warehouse": int(short["warehouse_simple"]["wh"])})

        if "warehouse" in short:
            short_data = short["warehouse"]["data"]
            warehouse.update(
                {"timestamp": ctime(), "warehouse": int(short_data["wh"]), "max": int(short_data["wh_all"])})
            warehouse_rest.update(
                {"timestamp": ctime(), "heal": int(short_data["heal"]), "heal_max": int(short_data["heal_all"]),
                 "alk": int(short_data["alk"]), "alk_all": int(short_data["alk_all"]),
                 "benz": int(short_data["benz"]), "benz_all": int(short_data["benz_all"])})
        if "capture" in short:
            short_capt = short["capture"]["data"]
            capture_data.update({"timestamp": ctime()})
            for bid in ["f0", "f1", "f2", "f3", "f4", "s0", "s1", "s2"]:
                capture_data.update({bid: {"t": short_capt[bid]["type"], "c": short_capt[bid]["control"]}})
        if "capture_next" in short:
            capture_next.update({"timestamp": ctime(), "next": ctime() + int(short["capture_next"]["next"])})


marker = {}


def process_marker(info, answer):
    global marker

    if 'marker' in info["data"]:
        marker = {
            "data": info["data"]["marker"],
            "timestamp": ctime()
        }

    if marker != {}:
        if ctime() - marker["timestamp"] > 30:
            marker = {}
        elif "marker_remove" in info["data"]:
            marker = {}

    if marker != {}:
        answer["marker"] = marker


async def process(info, answer):
    if 'auth' in info:
        return process_auth(info)
    else:
        if users[info['creds']['nick']] == info['creds']['pass']:
            clear_old()

            process_bikers(info)

            process_glonass(info, answer)

            process_acapture(info, answer)

            await process_deathlist(info, answer)

            process_capturetimer(info, answer)

            process_bikerinfo(info)

            process_marker(info, answer)
            
            process_admins(info, answer)

            answer["timestamp"] = time.time()

            return answer


@app.exception(NotFound)
async def test(request, exception):
    info = js.loads(urllib.parse.unquote(request.path[1:]))
    answer = {}
    answer["capter"] = ""
    return json(await process(info, answer))


async def ws(request, ws):
    while True:
        data = await ws.recv()
        info = js.loads(data)
        answer = {}
        answer["capter"] = ""
        res = js.dumps((await process(info, answer)))
        await ws.send(res)


app.config.WEBSOCKET_PING_INTERVAL = 86400
app.config.WEBSOCKET_PING_TIMEOUT = 86400

app.add_websocket_route(ws, "fast")

if __name__ == '__main__':
    database = Database('sqlite:///db/deathlist.db')
    asyncio.run(database.connect())

    startup_check("config/twinks.json")
    with open("config/twinks.json", "r") as fp:
        twinks["data"] = js.load(fp)

    with io.open('config/whitelist.txt') as file:
        for line in file:
            x = line.split()
            if len(x) == 2:
                users.update({x[0]: x[1]})

    if str(os.environ["enable_bikerinfo"]) == "1":
        from bikerinfo import bikerinfo

        bikerinfo_thread = threading.Thread(target=bikerinfo,
                                            args=[warehouse, warehouse_rest, capture_data, capture, capture_next])
        bikerinfo_thread.daemon = True
        bikerinfo_thread.start()

    if str(os.environ["enable_captureinfo"]) == "1":
        from captureinfo import captureinfo

        captureinfo_thread = threading.Thread(target=captureinfo,
                                              args=[textdraw, bikers, capture, capture_next])
        captureinfo_thread.daemon = True
        captureinfo_thread.start()

    if str(os.environ["enable_top"]) == "1":
        from topinfo import topinfo

        topinfo_thread = threading.Thread(target=topinfo, args=[twinks])
        topinfo_thread.daemon = True
        topinfo_thread.start()

    import top, crash_handle

    app.blueprint(top.bp)
    app.blueprint(crash_handle.bp)

    app.static('/resource', '/static/resource')
    app.static('version.json', '/static/version.json')
    app.static('edith.lua', '/static/edith.lua')

    app.run(host='0.0.0.0', port=33333, auto_reload=False, debug=False)
