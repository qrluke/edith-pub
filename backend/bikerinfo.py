import datetime
import os
import time

import pytz

from utils import ctime


def bikerinfo(warehouse, warehouse_rest, capture_data, capture, capture_next):
    import dico

    def unix2HM(unix):
        return datetime.datetime.utcfromtimestamp(unix).astimezone(pytz.timezone("Europe/Moscow")).strftime("%H:%M")

    def getCoolK(price):
        price = int(price)
        price = "%.1f" % (price / 1000)
        return price.replace(".0", "") + "K"

    api = dico.APIClient(os.environ["discord"], base=dico.HTTPRequest)

    channels = {
        "warehouse_guns": api.request_channel(os.environ["warehouse_guns"]),
        "warehouse_all": api.request_channel(os.environ["warehouse_all"]),
        "capture_next": api.request_channel(os.environ["capture_next"]),
        "capture_info": api.request_channel(os.environ["capture_info"]),
        "capture_emojis": api.request_channel(os.environ["capture_emojis"]),
        "capture_status": api.request_channel(os.environ["capture_status"]),
        "capture_letters": api.request_channel(os.environ["capture_letters"]),
    }

    last_info = {
        "warehouse_guns": "",
        "warehouse_all": "",
        "capture_next": "",
        "capture_info": "",
        "capture_emojis": "",
        "capture_status": "",
        "capture_letters": "",
    }

    emojis = {"Hells Angels MC": "\U0001F170",
              "Mongols MC": "\U0001F42D",
              "Pagans MC": "\U0001F43C",
              "Outlaws MC": "\U0001F414",
              "Sons of Silence MC": "\U0001F409",
              "Warlocks MC": "\U0001F349",
              "Highwaymen MC": "\U0001F6B5",
              "Bandidos MC": "\U0001F171",
              "Free Souls MC": "\U0001F921",
              "Vagos MC": "\U0001F913",
              "cur": "\U00002705"}

    def set(key, name):
        if name != last_info[key]:
            print(channels[key].edit(name=name))
            last_info[key] = name
            time.sleep(45)

    while True:
        if warehouse["timestamp"] != 0:
            string = f"\U0001F52B >> {getCoolK(warehouse['warehouse'])} << {unix2HM(warehouse['timestamp'])}"
            set("warehouse_guns", string)
        if warehouse_rest["timestamp"] != 0:
            string = f"\U0001F37A{warehouse_rest['alk']}\U0001F37A—\U000026FD{getCoolK(warehouse_rest['benz'])}\U000026FD— {unix2HM(warehouse_rest['timestamp'])}"
            set("warehouse_all", string)
        if capture_data["timestamp"] != 0:
            control = 0
            for bid in ["f0", "f1", "f2", "f3", "f4", "s0", "s1", "s2"]:
                if capture_data[bid]["c"] == os.environ["curb"]:
                    control += 1
            st_own = ""
            for bid in ["f0", "f1", "f2", "f3", "f4", "s0", "s1", "s2"]:
                st_own += capture_data[bid]["c"][0]
                if bid != "s2":
                    st_own += "—"
            st_em = ""
            for bid in ["f0", "f1", "f2", "f3", "f4", "s0", "s1", "s2"]:
                st_em += emojis[capture_data[bid]["c"]]
            st_st = ""
            for bid in ["f0", "f1", "f2", "f3", "f4", "s0", "s1", "s2"]:
                if capture_data[bid]["t"] == "r":
                    st_st += "\U0001F534"
                else:
                    st_st += "\U000026AA"
                    pass

            string = f"/capture >> {control}/8 << {unix2HM(capture_data['timestamp'])}"
            set("capture_info", string)
            set("capture_emojis", st_em)
            set("capture_letters", st_own)
            set("capture_status", st_st)

        if capture_next["timestamp"] != 0 and capture_next["next"] > ctime():
            string = f"next >> {unix2HM(capture_next['next'])}"
            set("capture_next", string)
        else:
            if "type" in capture:
                timeleft = capture["time"] + 60 * capture["type"] - ctime()
                if timeleft > 0:
                    if capture["type"] == 25:
                        string = f"\U0001F624 начало ч. {15 - int((ctime() - capture['time']) / 60)}м << {unix2HM(ctime())}"
                        set("capture_next", string)
                    elif capture['type'] == 10:
                        string = f"\U0001F621 конец ч. {10 - int((ctime() - capture['time']) / 60)}м << {unix2HM(ctime())}"
                        set("capture_next", string)
                    else:
                        string = f"\U0001F92C пот ост. {2 - int((ctime() - capture['time']) / 60)}м << {unix2HM(ctime())}"
                        set("capture_next", string)
                else:
                    string = f"next >> ??"
                    set("capture_next", string)
            else:
                string = f"next >> ??"
                set("capture_next", string)
        time.sleep(100)
