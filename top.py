import datetime
import io
import json as js
import sqlite3

import pandas as pd
import pytz
from sanic import Blueprint
from sanic.response import html

bp = Blueprint("top")

users = {}
twink = {}


def to_fixed(num, digits=0):
    return f"{num:.{digits}f}"


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


def getTop(cur, twink, timestamp, html=False):
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


def getAntiTop(cur, users, timestamp, html=False, min=3):
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


def getAdmTop(cur, timestamp, html=False):
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


@bp.route("/top")
async def test(request):
    with open("config/twinks.json", "r") as fp:
        twink = js.load(fp)
    users = {}
    with io.open('config/whitelist.txt') as file:
        for line in file:
            x = line.split()
            if len(x) == 2:
                users.update({x[0]: x[1]})
    day = datetime.datetime.now(pytz.timezone("Europe/Moscow"))
    timestamp = datetime.datetime.now(pytz.timezone("Europe/Moscow")).replace(hour=5, minute=0, second=0,
                                                                              microsecond=0).timestamp()
    if day.hour < 5:
        timestamp = timestamp - 86400

    day_top = getTop(cur, twink, timestamp, True)
    day_anti_top = getAntiTop(cur, users, timestamp, True)
    day_adm_top = getAdmTop(cur, timestamp, True)

    timestamp = (datetime.datetime.now(pytz.timezone("Europe/Moscow")) - datetime.timedelta(
        days=datetime.datetime.today().weekday())).replace(hour=5, minute=0, second=0, microsecond=0).timestamp()

    week_top = getTop(cur, twink, timestamp, True)
    week_anti_top = getAntiTop(cur, users, timestamp, True)
    week_adm_top = getAdmTop(cur, timestamp, True)

    all_top = getTop(cur, twink, 0, True)
    anti_top = getAntiTop(cur, users, 0, True)
    all_adm_top = getAdmTop(cur, 0, True)

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
