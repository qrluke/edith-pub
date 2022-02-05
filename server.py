#!/usr/bin/env python3
# edith server (2019)
import asyncio
import datetime
import io
import linecache
import os
import pandas as pd
import re
import sys
import time
import threading
import urllib.parse
from aiohttp import web
from databases import Database

last_cl = time.time()
last_c = time.time()

import sqlite3

con = sqlite3.connect('db/deathlist.db')
cur = con.cursor()

cur.executescript('''CREATE TABLE IF NOT EXISTS "dmg_out" (
	"id"	INTEGER,
	"timestamp"	INTEGER,
	"nick"	TEXT,
	"damage"	INTEGER,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "dmg_in" (
	"id"	INTEGER,
	"timestamp"	INTEGER,
	"nick"	TEXT,
	"damage"	INTEGER,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "kills" (
	"id"	INTEGER,
	"enable"	BLOB DEFAULT 1,
	"timestamp"	INTEGER,
	"killer"	TEXT,
	"killed"	TEXT,
	"weapon"	INTEGER,
	"skin"	INTEGER,
	"lvl"	INTEGER,
	"type"	TEXT,
	"score"	INTEGER,
	PRIMARY KEY("id" AUTOINCREMENT)
);''')
con.commit()


def ctime():
    return int(time.time())


try:
    sys.argv[1]
    int(sys.argv[1])
except IndexError:
    print("usage: python3 server3.py [DELAY (MS)]")
    sys.exit(0)

DELAY = int(sys.argv[1])

nicks = {}
vehicles = {}
capture = {}
capters = {}
capterslist = []

users = {}

last_changed = 0
import re

from sanic import Sanic
from sanic.response import json
from sanic.response import html
from sanic.response import text
from sanic.exceptions import NotFound
import json as js

admins = ["Nick_Name"]

app = Sanic(name='edith-server')

skins_army = [287, 191]
skins_gos = [165, 166, 280, 281, 282, 283, 284, 285, 286, 288, 300, 301, 302, 303, 304, 305, 306, 307, 309, 310, 311,
             163, 164]
skins_ghetto = [114, 115, 116, 292, 41, 173, 174, 175, 226, 273, 105, 106, 107, 56, 269, 270, 271, 102, 103, 104, 195,
                108, 109, 110, 190]
skins_bikers = [247, 248, 254, 100, 181, 178, 246]

import pytz


def to_fixed(num, digits=0):
    return f"{num:.{digits}f}"


twink = {}


def getTop(timestamp, html=False):
    day = []
    for i in cur.execute(
            "SELECT `killer`,  SUM(score) AS `score`, COUNT(*) AS `kills` FROM `kills` WHERE (`type` = 'normal' or `type` = 'dm') and `timestamp` > :unix  GROUP BY  `killer` ORDER BY `score` DESC",
            {"unix": timestamp}).fetchall():
        d = {}
        d["killer"] = i[0]
        d["score"] = i[1]
        d["kills"] = i[2]
        d["deaths"] = cur.execute(
            "SELECT COUNT(*) FROM `kills` WHERE type == 'died' AND killer != 'nil' AND timestamp > :unix AND killed == :nick",
            {"nick": d["killer"], "unix": timestamp}).fetchone()[0]
        try:
            d["K/D"] = to_fixed(d["kills"] / d["deaths"], 1)
        except ZeroDivisionError:
            d["K/D"] = ""
        d["suicides"] = cur.execute(
            "SELECT COUNT(*) FROM `kills` WHERE type == 'died' AND killer == 'nil' AND timestamp > :unix AND killed == :nick",
            {"nick": d["killer"], "unix": timestamp}).fetchone()[0]
        d["dmg out"] = cur.execute("SELECT SUM(damage) FROM `dmg_out` WHERE timestamp > :unix AND nick == :nick",
                                   {"nick": d["killer"], "unix": timestamp}).fetchone()[0]
        d["dmg in"] = cur.execute("SELECT SUM(damage) FROM `dmg_in` WHERE timestamp > :unix AND nick == :nick",
                                  {"nick": d["killer"], "unix": timestamp}).fetchone()[0]
        d["demorgan"] = \
            cur.execute("SELECT SUM(lvl) FROM `kills` WHERE timestamp > :unix AND killer == :nick AND type == 'dm'",
                        {"nick": d["killer"], "unix": timestamp}).fetchone()[0]
        for k, v in d.items():
            if v == None:
                d[k] = 0
        if d["score"] < 0:
            d["score"] = 0
        day.append(d)

    day_new = {}

    for i in day:
        done = False
        for k, v in twink.items():
            if i["killer"] in v:
                if k in day_new:
                    day_new[k]["score"] += i["score"]
                    day_new[k]["kills"] += i["kills"]
                    day_new[k]["deaths"] += i["deaths"]
                    try:
                        day_new[k]["K/D"] = to_fixed(day_new[k]["kills"] / day_new[k]["deaths"], 1)
                    except ZeroDivisionError:
                        day_new[k]["K/D"] = ""
                    day_new[k]["suicides"] += i["suicides"]
                    day_new[k]["dmg out"] += i["dmg out"]
                    day_new[k]["dmg in"] += i["dmg in"]
                    day_new[k]["demorgan"] += int(i["demorgan"])
                else:
                    day_new[k] = {}
                    day_new[k]["killer"] = k
                    day_new[k]["score"] = i["score"]
                    day_new[k]["kills"] = i["kills"]
                    day_new[k]["deaths"] = i["deaths"]
                    try:
                        day_new[k]["K/D"] = to_fixed(i["kills"] / i["deaths"], 1)
                    except ZeroDivisionError:
                        day_new[k]["K/D"] = ""
                    day_new[k]["suicides"] = i["suicides"]
                    day_new[k]["dmg out"] = i["dmg out"]
                    day_new[k]["dmg in"] = i["dmg in"]
                    day_new[k]["demorgan"] = int(i["demorgan"])
                done = True
                break
        if not done:
            day_new[i["killer"]] = i

    day_new = dict(sorted(day_new.items(), key=lambda item: item[1]['score'], reverse=True))

    i = 1
    if html:
        b = {}
        df = pd.DataFrame(data=b)
        for k, v in day_new.items():
            b[i] = v
            i += 1
        df = pd.DataFrame(data=b)
        df = df.fillna(' ').T
        return df.to_html(escape=False)
    else:
        top = {}
        i = 1
        for k, v in day_new.items():
            top[i] = v
            i += 1
        return top


def getAntiTop(timestamp, html=False, min=3):
    day = []
    for i in cur.execute(
            "SELECT `killer`, COUNT(*) AS `kills` FROM `kills` WHERE `type` = 'died' and `timestamp` > :unix  GROUP BY  `killer` ORDER BY `kills` DESC",
            {"unix": timestamp}).fetchall():
        if i[0] not in users and i[0] != '' and i[0] != 'nil' and i[1] >= min:
            d = {}
            d["killer"] = i[0]
            d["kills"] = i[1]
            day.append(d)

    if html:
        b = {}
        i = 1
        for v in day:
            b[i] = v
            i += 1
        df = pd.DataFrame(data=b)
        df = df.fillna(' ').T
        return df.to_html(escape=False)
    else:
        top = {}
        i = 1
        for v in day:
            top[i] = v
            i += 1
        return top


def getAdmTop(timestamp, html=False):
    day = []
    for i in cur.execute(
            "SELECT `killed`, SUM(lvl) AS `min` FROM `kills` WHERE `type` = 'dm' and `timestamp` > :unix  GROUP BY  `killed` ORDER BY `min` DESC",
            {"unix": timestamp}).fetchall():
        d = {}
        d["adm"] = i[0]
        d["min"] = i[1]
        day.append(d)

    if html:
        b = {}
        i = 1
        for v in day:
            b[i] = v
            i += 1
        df = pd.DataFrame(data=b)
        df = df.fillna(' ').T
        return df.to_html(escape=False)
    else:
        top = {}
        i = 1
        for v in day:
            top[i] = v
            i += 1
        return top


@app.route('/top')
async def test(request):
    global twink
    with open("config/twinks.json", "r") as fp:
        twink = js.load(fp)
    day = datetime.datetime.now(pytz.timezone("Europe/Moscow"))
    timestamp = datetime.datetime.now(pytz.timezone("Europe/Moscow")).replace(hour=5, minute=0, second=0,
                                                                              microsecond=0).timestamp()
    if day.hour < 5:
        timestamp = timestamp - 86400

    day_top = getTop(timestamp, True)
    day_anti_top = getAntiTop(timestamp, True)
    day_adm_top = getAdmTop(timestamp, True)

    timestamp = (datetime.datetime.now(pytz.timezone("Europe/Moscow")) - datetime.timedelta(
        days=datetime.datetime.today().weekday())).replace(hour=5, minute=0, second=0, microsecond=0).timestamp()

    week_top = getTop(timestamp, True)
    week_anti_top = getAntiTop(timestamp, True)
    week_adm_top = getAdmTop(timestamp, True)

    all_top = getTop(0, True)
    anti_top = getAntiTop(0, True)
    all_adm_top = getAdmTop(0, True)

    b = {}
    i = 1
    for k, v in twink.items():
        for kk in v:
            b[i] = {
                "group": k,
                "nick": kk
            }
            i += 1
    df = pd.DataFrame(data=b)
    df = df.fillna(' ').T
    twinks_html = df.to_html(escape=False)

    b = {}
    for i in cur.execute(
            "SELECT id, timestamp, type, killer, score, killed, weapon, skin, lvl FROM kills ORDER BY id DESC").fetchall():
        b[i[0]] = {
            "timestamp": datetime.datetime.fromtimestamp(i[1]),
            "type": i[2],
            "killer": i[3],
            "score": i[4],
            "killed": i[5],
            "weapon": i[6],
            "skin": i[7],
            "lvl": i[8]
        }

        if b[i[0]]["score"] < 0:
            b[i[0]]["score"] = 0

    df = pd.DataFrame(data=b)
    df = df.fillna(' ').T
    return html(
        f"""
<b>Правила</b>
<br>* Сюда попадают всё убийства и смерти пользователей эдита.
<br>* Для каждого убийства считаются очки, есть топ по ним.
<br>* Известные твинки в топе считаются за одного участника.
<br>* Для учёта нужно включить серверный дамаг информер в /mm (текст и 3д текст).
<br>* День начинается в 5 утра по мск, неделя в пн в 5 утра по мск.
<br>
<br><b>Очки:</b><br>* Смерть: +0
<br>* Убийство в афк: +0.5
<br>* Убийство гражданского: +1
<br>* Убийство геттора: +2
<br>* Убийство байкера: +2
<br>* Убийство военного: +3
<br>* Убийство пд/фбр: +5
<br>* Попадание в деморган: +5
<br>* Убийство игрока 1-3 уровня: x2
<br>
<br><b>Штрафы:</b>
<br>* Убийство пользователя эдита: -1
<br>* Убийство админа эдита: -10
<br>
<br><b>Твинки:</b>
<br>
<details>Список известных эдиту твинков, счет будет суммироваться в топе.
<br>Если вас нет, напишите федуку в дискорде, я вас добавлю.
<br>{twinks_html}
</details>
<br><b>day top</b>
<br>{day_top}
<br><b>day antitop</b>
<br><details>{day_anti_top}</details>
<br><b>day admtop</b>
<br><details>{day_adm_top}</details>
<br><b>week top</b>
<br>{week_top}
<br><b>week antitop</b>
<br><details>{week_anti_top}</details>
<br><b>week admtop</b>
<br><details>{week_adm_top}</details>
<br><b>all top</b>
<br>{all_top}
<br><b>anti_top</b>
<br><details>{anti_top}</details>
<br><b>all admtop</b>
<br><details>{all_adm_top}</details>
<br><b>log</b>
<br><details>{df.to_html(escape=False)}</details>
""")


death_list = []

warehouse = {"timestamp": 0, "warehouse": 0, "max": 200000}
warehouse_rest = {"timestamp": 0, "heal": 0, "heal_max": 5000, "alk": 0, "alk_all": 0, "benz": 0, "benz_all": 0}
capture_data = {"timestamp": 0, "f0": {"t": "w", "c": "mc"}, "f1": {"t": "w", "c": "mc"}, "f2": {"t": "w", "c": "mc"},
                "f3": {"t": "w", "c": "mc"}, "f4": {"t": "w", "c": "mc"}, "s0": {"t": "w", "c": "mc"},
                "s1": {"t": "w", "c": "mc"}, "s2": {"t": "w", "c": "mc"}}
capture_next = {"timestamp": 0, "next": 0}

marker = {}


@app.exception(NotFound)
async def test(request, exception):
    global last_cl
    global last_c
    global last_changed
    global balance
    global death_list
    global marker

    timer = time.time()
    info = js.loads(urllib.parse.unquote(request.path[1:]))
    answer = {}
    answer["capter"] = ""
    if 'auth' in info:
        if last_changed != os.stat("config/whitelist.txt").st_mtime:
            with io.open('config/whitelist.txt') as file:
                for line in file:
                    x = line.split()
                    if len(x) == 2:
                        users.update({x[0]: x[1]})
            last_changed = os.stat("config/whitelist.txt").st_mtime

        if info['auth'] not in users:
            return json({"result": "wrong user"})
        else:
            if info['password'] == users[info['auth']]:
                return json({"result": "ok", "like": list(users.keys()), "delay": DELAY})
            else:
                return json({"result": "wrong password", "delay": DELAY})
        return json({"result": "error", "timestamp": 'Go away!'})
    else:
        if users[info['creds']['nick']] == info['creds']['pass']:
            if time.time() - last_c > 300:
                last_c = time.time()
                del_nicks_list = []
                del_veh_list = []
                for k, v in nicks.items():
                    if time.time() - v["timestamp"] > 300:
                        del_nicks_list.append(k)
                for k in del_nicks_list:
                    if k in nicks:
                        del nicks[k]
                for k, v in vehicles.items():
                    if time.time() - v["timestamp"] > 300:
                        del_veh_list.append(k)
                for k in del_veh_list:
                    if k in vehicles:
                        del vehicles[k]

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
            if 'sender' in info["data"]:
                nicks.update({info["data"]['sender']['sender']: {
                    'timestamp': time.time(),
                    'heading': info["data"]['sender']['heading'],
                    'health': info["data"]['sender']['health'],
                    'x': info["data"]['sender']['pos']['x'],
                    'y': info["data"]['sender']['pos']['y'],
                    'z': info["data"]['sender']['pos']['z'],
                }})
            if 'vehicles' in info["data"]:
                inf = info["data"]['vehicles']
                for a in inf:
                    if a and a['id'] not in vehicles:
                        if 'health' in a:
                            vehicles.update({a['id']: {
                                'timestamp': time.time(),
                                'heading': a['heading'],
                                'engine': a['engine'],
                                'health': a['health'],
                                'healthstamp': time.time(),
                                'x': a['pos']['x'],
                                'y': a['pos']['y'],
                                'z': a['pos']['z'],
                            }})
                        else:
                            vehicles.update({a['id']: {
                                'timestamp': time.time(),
                                'heading': a['heading'],
                                'engine': a['engine'],
                                'x': a['pos']['x'],
                                'health': 'xz',
                                'healthstamp': time.time(),
                                'y': a['pos']['y'],
                                'z': a['pos']['z'],
                            }})
                    else:
                        if vehicles[a['id']]['timestamp'] < time.time():
                            if 'health' in a:
                                vehicles.update({a['id']: {
                                    'timestamp': time.time(),
                                    'heading': a['heading'],
                                    'engine': a['engine'],
                                    'health': a['health'],
                                    'healthstamp': time.time(),
                                    'x': a['pos']['x'],
                                    'y': a['pos']['y'],
                                    'z': a['pos']['z'],
                                }})
                            else:
                                vehicles.update({a['id']: {
                                    'timestamp': time.time(),
                                    'heading': a['heading'],
                                    'engine': a['engine'],
                                    'health': vehicles[a['id']]['health'],
                                    'healthstamp': vehicles[a['id'
                                    ]]['healthstamp'],
                                    'x': a['pos']['x'],
                                    'y': a['pos']['y'],
                                    'z': a['pos']['z'],
                                }})
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
            if "getDeathList" in info["data"]:
                answer["deathList"] = death_list

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

            if info["data"]['request'] == 0:
                answer["capture"] = capture
                answer["timestamp"] = time.time()
            elif info["data"]['request'] == 1:
                answer["capture"] = capture
                answer["timestamp"] = time.time()
                answer["nicks"] = nicks
                answer["vehicles"] = vehicles
            return json(answer)
            # server.send_message(client, str.encode())
            # print ('Client(%d) said: %s' % (client['id'], message))
            # print ('Client(%d) answered: %s' % (client['id'], str.encode(js.dumps(answer))))
    return text("error")


def startupCheck(PATH):
    if os.path.exists(PATH) and os.access(PATH, os.R_OK):
        # checks if file exists
        print("File exists and is readable")
    else:
        print("Either file is missing or is not readable, creating file...")
        with io.open(PATH, 'w') as db_file:
            db_file.write(js.dumps({}))


def bikerinfo():
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
              "Warlocks MC": "\U00002694",
              "Highwaymen MC": "\U0001F6B5",
              "Bandidos MC": "\U0001F171",
              "Free Souls MC": "\U0001F921",
              "Vagos MC": "\U0001F913",
              "cur": "\U00002705"}

    def set(key, name):
        if name != last_info[key]:
            print(channels[key].edit(name=name))
            last_info[key] = name
            time.sleep(15)

    while True:
        if warehouse["timestamp"] != 0:
            string = f"\U0001F52B >> {getCoolK(warehouse['warehouse'])} << {unix2HM(warehouse['timestamp'])}"
            set("warehouse_guns", string)
        if warehouse_rest["timestamp"] != 0:
            string = f"\U0001F37A{warehouse_rest['alk']}\U0001F37A—\U000026FD{getCoolK(warehouse_rest['benz'])}\U000026FD—{unix2HM(warehouse_rest['timestamp'])}"
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

            string = f"/capture >> {control}/8 << {unix2HM(warehouse_rest['timestamp'])}"
            set("capture_info", string)
            print(st_em)
            set("capture_emojis", st_em)
            print(st_own)
            set("capture_letters", st_own)
            print(st_st)
            set("capture_status", st_st)

        if capture_next["timestamp"] != 0:
            if capture_next["next"] > ctime():
                string = f"next >> {unix2HM(capture_next['next'])}"
                set("capture_next", string)
            else:
                string = f"next >> ??"
                set("capture_next", string)
        time.sleep(120)


if __name__ == '__main__':
    database = Database('sqlite:///db/deathlist.db')
    asyncio.run(database.connect())

    startupCheck("config/twinks.json")
    with open("config/twinks.json", "r") as fp:
        twink = js.load(fp)

    with io.open('config/whitelist.txt') as file:
        for line in file:
            x = line.split()
            if len(x) == 2:
                users.update({x[0]: x[1]})

    if str(os.environ["enable_discord"]) == "1":
        test_thread = threading.Thread(target=bikerinfo)
        test_thread.daemon = True
        test_thread.start()

    app.run(host='0.0.0.0', port=33333, auto_reload=True, debug=False)
