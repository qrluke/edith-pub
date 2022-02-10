import feedparser
import pickle
import re
import threading
import io
import time
import requests
import os
import dico
import requests

from bs4 import BeautifulSoup

api = dico.APIClient(os.environ["discord_jb"], base=dico.HTTPRequest)

jalobi = {
    "Revolution": [
        "https://samp-rp.su/forums/zhaloby-na-igrokov-sostojaschix-v-bandax.1155/index.rss",
        "https://samp-rp.su/forums/zhaloby-na-igrokov-sostojaschix-v-mafii.1154/index.rss",
        "https://samp-rp.su/forums/zhaloby-na-igrokov-sostojaschix-v-gos-organizacijax.1157/index.rss",
        "https://samp-rp.su/forums/zhaloby-na-igrokov-sostojaschix-v-bajkerax.1153/index.rss",
        "https://samp-rp.su/forums/zhaloby-na-igrokov-sostojaschix-v-novostjax.1156/index.rss",
        "https://samp-rp.su/forums/zhaloby-na-igrokov-ne-sostojaschix-v-organizacijax.1151/index.rss",
        "https://samp-rp.su/forums/zhaloby-na-vyxod-iz-igry-pri-areste.1152/index.rss",
        "https://samp-rp.su/forums/zhaloby-na-liderov-frakcij.1158/"
    ]
}


def read(filename):
    with open(filename, 'rb') as filehandle:
        return pickle.load(filehandle)


def dump(object, filename):
    with open(filename, 'wb') as filehandle:
        return pickle.dump(object, filehandle)


try:
    sent = read('sent')
except FileNotFoundError:
    dump([], 'sent')
    sent = read('sent')

regex_html = re.compile('<.*?>|&([a-z0-9]+|#[0-9]{1,6}|#x[0-9a-f]{1,6});')


def post_embed(item, title):
    embed = dico.Embed(
        title=f"Жалоба: '{item['title']}'",
        url=item["id"],
        description=re.sub(regex_html, '', item["summary"]),
        timestamp=time.strftime('%Y-%m-%dT%H:%M:%S', item["published_parsed"]),
        color=0x348cb2,
    )
    embed.set_author(name=item["authors"][0]["name"])
    embed.add_field(name="Ваш никнейм", value=item["parsed_thread"]["form"][0], inline=True)
    embed.add_field(name="Ваша фракция", value=item["parsed_thread"]["form"][1], inline=True)
    embed.add_field(name="Триггер", value=item["trigger"], inline=True)
    embed.add_field(name="Суть нарушения", value=item["parsed_thread"]["form"][2], inline=True)
    embed.add_field(name="Доказательства", value=item["parsed_thread"]["form"][3], inline=False)
    if len(item["parsed_thread"]['links']) > 0:
        links = ""
        for link in item["parsed_thread"]["links"]:
            links = links + link + "\n"
        if links.replace("\n", "") != item["parsed_thread"]["form"][3]:
            embed.add_field(name="Все ссылки", value=f"{links}", inline=False)
    embed.set_thumbnail(url=item["parsed_thread"]["avatar"])
    embed.set_footer(text=title)

    affected_nicks = []
    for nick in nicks:
        if nick.upper() in item["title"].upper() or nick.upper() in item["summary"].upper():
            affected_nicks.append(nick)
    print(affected_nicks)

    affected_people = []
    for k, v in twinks.items():
        for nick in v:
            if nick in affected_nicks:
                if k not in affected_people:
                    affected_people.append(k)
    print(affected_people)

    affected_discord_ids = []
    for man in affected_people:
        if man in discord:
            affected_discord_ids.append(discord[man])
    print(affected_discord_ids)

    if len(affected_discord_ids) > 0:
        mention = ""
        for id in affected_discord_ids:
            mention = mention + f"<@{id}> "
        mention += "повістка"
        api.create_message(os.environ["channel_jb"], embed=embed, content=mention)
    else:
        api.create_message(os.environ["channel_jb"], embed=embed)


def parse_thread(url):
    try:
        r = requests.get(url)
        soup = BeautifulSoup(r.text, 'lxml')
        item = soup.find_all("div", class_="message-inner")[0]
        images = [img.get('src') for img in item.find_all('img', src=True)]

        avatar = "https://cdn.discordapp.com/attachments/567831154833752132/568463937759215616/ava.png"
        if len(images) > 0:
            if avatar.find("avatars") == -1:
                avatar = "https://samp-rp.su/" + images[0]

        mes = item.find_all("div", "message-cell message-cell--main")
        links = [a.get('href') for a in mes[0].find_all('a', href=True)]
        form = [dd.get('title') for dd in
                item.find_all("div", "message-fields message-fields--before")[0].find_all("dd")]
        res = []
        for i in links:
            if i.find("http") != -1:
                res.append(i)
        return {"avatar": avatar, "links": res, "form": form}
    except Exception as E:
        print(E)
        return {"avatar": "https://cdn.discordapp.com/avatars/938907282794745946/0767a32ba423f2cce121a8ed6e366262.webp",
                "links": [], "form": [str(E), "-", "-", "-"]}


def parse(url, trigger):
    time.sleep(1)
    rss = feedparser.parse(url)
    for item in rss["entries"]:
        for k in trigger:
            if ("content" in item and item["content"][0]["value"].upper().find(k.upper()) != -1) or (
                    'title' in item and item['title'].upper().find(
                k.upper()) != -1):
                item["id"] = re.sub('threads/(.+)\.', 'threads/', item["id"])
                if item["id"] not in sent:
                    time.sleep(1)
                    item["parsed_thread"] = parse_thread(item["id"])
                    item["trigger"] = k
                    post_embed(item, rss["feed"]["title"])
                    sent.append(item["id"])
                    dump(sent, "sent")
                    print(item["id"], item["authors"][0]["name"], item["title"])


nicks = []
twinks = []
discord = []

last_changed_n = 0
last_changed_t = 0
last_changed_d = 0

import json

while True:
    if os.environ["enable_jb"] == "0":
        break

    if last_changed_n != os.stat("config/whitelist.txt").st_mtime:
        with io.open('config/whitelist.txt') as file:
            nicks = []
            for line in file:
                x = line.split()
                if len(x) == 2:
                    nicks.append(x[0])
                    nicks.append(x[0].replace("_", " "))
        last_changed_n = os.stat("config/whitelist.txt").st_mtime

    if last_changed_t != os.stat("config/twinks.json").st_mtime:
        with io.open('config/twinks.json') as file:
            twinks_s = json.loads(file.read())
            twinks = {}
            for k, v in twinks_s.items():
                twinks[k] = []
                for nick in v:
                    twinks[k].append(nick.replace("_", " "))
                    twinks[k].append(nick)

        last_changed_t = os.stat("config/twinks.json").st_mtime

    if last_changed_d != os.stat("config/discord.json").st_mtime:
        with io.open('config/discord.json') as file:
            discord = json.loads(file.read())
        last_changed_d = os.stat("config/discord.json").st_mtime

    for k, v in jalobi.items():
        for link in v:
            parse(link, nicks)

    time.sleep(60)

time.sleep(9999999)
