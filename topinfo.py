import datetime
import io
import json as js
import os
import pickle
import sqlite3
import time

import dico
import pytz
from schedule import every, repeat, run_pending
from table2ascii import table2ascii, Alignment

from top import getTop

from utils import startup_check


def topinfo(twinks):
    startup_check('config/discord.json')
    startup_check('config/twinks.json')

    con = sqlite3.connect('db/deathlist.db')
    cur = con.cursor()

    api = dico.APIClient(os.environ["discord"], base=dico.HTTPRequest)
    chn = int(os.environ["top_channel"])

    button = dico.Button(
        style=dico.ButtonStyles.LINK, label="Подробнее", url=os.environ["top_link"]
    )
    row = dico.ActionRow(button)

    button1 = dico.Button(
        style=dico.ButtonStyles.LINK, label="Топ", url=os.environ["top_link_discord"]
    )
    row_top = dico.ActionRow(button1)

    def read(filename):
        with open(filename, 'rb') as filehandle:
            return pickle.load(filehandle)

    def dump(object, filename):
        with open(filename, 'wb') as filehandle:
            return pickle.dump(object, filehandle)

    try:
        edit = read('top')
    except FileNotFoundError:
        dump({"all": 0, "week": 0, "day": 0}, 'top')
        edit = read('top')

    def genAsciiTable(result, limit=99):
        body = []
        sum = ["", os.environ["top_name"], 0, 0, 0, 0, 0]
        header = ["№", "player", "score", "kills", "deaths", "K/D", "dm"]

        last_output = table2ascii(
            header=header,
            body=body,
            footer=sum,
            first_col_heading=True
        )

        cur = 0

        for k, v in result.items():
            body.append(
                [k, v["killer"][:13], v["score"], v["kills"], v["deaths"], v["K/D"],
                 v["demorgan"]])

            sum[2] += v["score"]
            sum[3] += v["kills"]
            sum[4] += v["deaths"]
            try:
                sum[5] = "{:.1f}".format(sum[3] / sum[4])
            except ZeroDivisionError:
                sum[5] = "n/a"
            sum[6] += v["demorgan"]

            new_output = table2ascii(
                header=header,
                body=body,
                footer=sum,
                first_col_heading=True,
                alignments=[Alignment.LEFT] + [Alignment.LEFT] + [Alignment.RIGHT] * 5,
            )
            if len(new_output) > 1980 or cur == limit:
                return last_output
            else:
                cur += 1
                last_output = new_output

        return last_output

    @repeat(every(15).minutes)
    def upd_twinks():
        with open("config/twinks.json", "r") as fp:
            twinks["data"] = js.load(fp)

    @repeat(every(5).minutes)
    def upd_all():
        embed = dico.Embed(
            title=f"За всё время",
            description=f"```markdown\n{genAsciiTable(getTop(cur, twinks['data'], 0, False))}```",
            timestamp=time.strftime('%Y-%m-%dT%H:%M:%S', time.gmtime()),
            color=0x348cb2,
        )
        embed.set_footer(text="Топ пользователей edith за всё время")
        if edit["all"] == 0:
            edit["all"] = int(api.create_message(chn, embed=embed).id)
            dump(edit, "top")
        else:
            api.edit_message(chn, edit["all"], embed=embed)

    @repeat(every(5).minutes)
    def upd_week():
        day = datetime.datetime.now(pytz.timezone("Europe/Moscow"))
        timestamp = (datetime.datetime.now(pytz.timezone("Europe/Moscow")) - datetime.timedelta(
            days=datetime.datetime.today().weekday())).replace(hour=5, minute=0, second=0, microsecond=0).timestamp()

        if day.hour < 5:
            timestamp = timestamp - 86400

        embed = dico.Embed(
            title=f"За неделю",
            description=f"```markdown\n{genAsciiTable(getTop(cur, twinks['data'], timestamp, False))}```",
            timestamp=time.strftime('%Y-%m-%dT%H:%M:%S', time.gmtime()),
            color=0x348cb2,
        )
        embed.set_footer(text="Топ пользователей edith за неделю")
        if edit["week"] == 0:
            edit["week"] = int(api.create_message(chn, embed=embed).id)
            dump(edit, "top")
        else:
            api.edit_message(chn, edit["week"], embed=embed)

    @repeat(every(5).seconds)
    def upd_day():
        day = datetime.datetime.now(pytz.timezone("Europe/Moscow"))
        timestamp = datetime.datetime.now(pytz.timezone("Europe/Moscow")).replace(hour=5, minute=0, second=0,
                                                                                  microsecond=0).timestamp()
        if day.hour < 5:
            timestamp = timestamp - 86400

        embed = dico.Embed(
            title=f"За сутки",
            description=f"```markdown\n{genAsciiTable(getTop(cur, twinks['data'], timestamp, False))}```",
            timestamp=time.strftime('%Y-%m-%dT%H:%M:%S', time.gmtime()),
            color=0x348cb2,
        )
        embed.set_footer(text="Топ пользователей edith за сутки (с 05:00)")
        time.sleep(1)
        if edit["day"] == 0:
            edit["day"] = int(api.create_message(chn, embed=embed, component=row).id)
            dump(edit, "top")
        else:
            api.edit_message(chn, edit["day"], embed=embed, component=row)

    @repeat(every().day.at("01:40"))
    def send_report():
        day = datetime.datetime.now(pytz.timezone("Europe/Moscow"))
        timestamp = datetime.datetime.now(pytz.timezone("Europe/Moscow")).replace(hour=5, minute=0, second=0,
                                                                                  microsecond=0).timestamp()
        if day.hour < 5:
            timestamp = timestamp - 86400

        top = getTop(cur, twinks['data'], timestamp, False)

        if len(top) > 0:
            with io.open('config/discord.json') as file:
                discord = js.loads(file.read())

            embed = dico.Embed(
                title=f"Доска почёта",
                description=f"```markdown\n{genAsciiTable(getTop(cur, twinks['data'], timestamp, False), 5)}```",
                timestamp=time.strftime('%Y-%m-%dT%H:%M:%S', time.gmtime()),
                color=0x4D220E,
            )
            embed.set_footer(text="Топ-5 за последние сутки")

            if top[1]["killer"] in discord:
                mention = f"<@{discord[top[1]['killer']]}> — герой дня! Поздравляем! Ура! Ура! Ура!"

                api.create_message(os.environ["channel_flood"], content=str(mention), embed=embed, component=row_top)
            else:
                api.create_message(os.environ["channel_flood"], embed=embed, component=row_top)

    while True:
        run_pending()
        time.sleep(1)
