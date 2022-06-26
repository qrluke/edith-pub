import re
import time
from sanic import Blueprint
import httpx
from sanic.response import json

bp = Blueprint("parse_admins")
last_time = 0
cached_admins = []

@bp.route('/parse_admins')
async def parse_admins(request):
    global last_time
    global cached_admins
    if time.time() - last_time > 600:
        async with httpx.AsyncClient(timeout=30.0) as client:
            html_admins = (await client.get("https://samp-rp.su/threads/administracija-proekta-samp-rp.2050107/")).text
        result = []
        for adm in re.findall("([A-Z]{1}[a-z]{1,20}[_][A-Z]{1}[a-z]{1,20}).+сервера (.*)\..+([0-9]{1,2}[ ]lvl)", html_admins):
            result.append({"server": adm[1], "name": adm[0], "lvl": adm[2]})
        result.append({"server": "head", "name": "Flazy_Fad", "lvl": 10})
        result.append({"server": "head", "name": "Donny_Hayes", "lvl": 10})
        result.append({"server": "head", "name": "El_Capone", "lvl": 9})
        if len(result) > 3:
            cached_admins = result
            print("new cached admins")
            last_time = time.time()

    return json({"result": "ok", "data": cached_admins, "update":last_time})
