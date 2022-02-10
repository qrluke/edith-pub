import datetime
import os
import urllib.parse
import time
import json as js

from sanic import Blueprint
from sanic.response import text
from discord_webhook import DiscordWebhook, DiscordEmbed

bp = Blueprint("crash_handle")


@bp.route('/crash_report/<data:[^/].*?>')
async def handle_crash_report(request, data: str):
    crash = js.loads(urllib.parse.unquote(data))

    webhook = DiscordWebhook(url=os.environ["crash_webhook"])

    crash['data'] = crash['data'].replace('$$$$n', '\n').replace('$$$$t', '\t')

    embed = DiscordEmbed(
        description=f"```lua\n{crash['data']}```",
        title=f"New crash report",
        color=242424,
        timestamp=time.strftime('%Y-%m-%dT%H:%M:%S', time.gmtime())
    )

    embed.set_author(
        name=crash["nick"],
    )

    embed.set_footer(text=f"Автоматически отправленное сообщение об ошибке")

    embed.add_embed_field(name="edith version", value=crash["sv"])
    embed.add_embed_field(name="moon version", value=crash["v"])
    embed.add_embed_field(name="Online", value=str(datetime.timedelta(seconds=int(crash["clock"]))))

    webhook.add_embed(embed)
    webhook.execute()

    return text('ok')
