script_name("E.D.I.T.H.")
script_author("qrlk") --большая часть модулей самописная, часть взята из доработанных мной сторонних скриптов
script_version("26.06.2022-stable")
script_description("Это модульный скрипт для небольших закрытых сообществ игроков. Идея в том, чтобы впихнуть в один скрипт все нужные конкретной группе игроков скрипты в виде модулей. Модули можно настраивать, а сам скрипт защитить паролем и обмениваться информацией через модуль clientModule(). Эту информацию можно использовать в модулях, например обмениваться местоположением членов группы, показывать общий килллист, считать статистику KDA на сервере...")
script_url("https://github.com/qrlk/edith-pub")
--script_properties("work-in-pause")

--поменять
local ip = "http://localhost:33333/" --ip и порт сервера server.py (python3 server.py после pip3 install -r requirements.txt)
local wip = "ws://localhost:33333/fast" --ip и порт сервера server.py (python3 server.py после pip3 install -r requirements.txt)
local remoteResourceURL = ip .. "resource/edith/" --путь туда, где хостится папки resource/edith
local serverAddress = "127.0.0.1" --сервер, где вы играете

local ckey1, ckey2 = nil, nil -- кастомный ключ для cipherModule()

local enableErrorReporter = true --включить подгрузку фонового скрипта, который будет отправлять на сервер информацию о вылетах? информация обратывается на сервере через handle_crash_report(), в моём случае используется discord webhook

-- https://github.com/qrlk/qrlk.lua.moonloader
local enable_sentry = true -- false to disable error reports to sentry.io
if enable_sentry then
  local sentry_loaded, Sentry = pcall(loadstring, [=[return {init=function(a)local b,c,d=string.match(a.dsn,"https://(.+)@(.+)/(%d+)")local e=string.format("https://%s/api/%d/store/?sentry_key=%s&sentry_version=7&sentry_data=",c,d,b)local f=string.format("local target_id = %d local target_name = \"%s\" local target_path = \"%s\" local sentry_url = \"%s\"\n",thisScript().id,thisScript().name,thisScript().path:gsub("\\","\\\\"),e)..[[require"lib.moonloader"script_name("sentry-error-reporter-for: "..target_name.." (ID: "..target_id..")")script_description("Этот скрипт перехватывает вылеты скрипта '"..target_name.." (ID: "..target_id..")".."' и отправляет их в систему мониторинга ошибок Sentry.")local a=require"encoding"a.default="CP1251"local b=a.UTF8;local c="moonloader"function getVolumeSerial()local d=require"ffi"d.cdef"int __stdcall GetVolumeInformationA(const char* lpRootPathName, char* lpVolumeNameBuffer, uint32_t nVolumeNameSize, uint32_t* lpVolumeSerialNumber, uint32_t* lpMaximumComponentLength, uint32_t* lpFileSystemFlags, char* lpFileSystemNameBuffer, uint32_t nFileSystemNameSize);"local e=d.new("unsigned long[1]",0)d.C.GetVolumeInformationA(nil,nil,0,e,nil,nil,nil,0)e=e[0]return e end;function getNick()local f,g=pcall(function()local f,h=sampGetPlayerIdByCharHandle(PLAYER_PED)return sampGetPlayerNickname(h)end)if f then return g else return"unknown"end end;function getRealPath(i)if doesFileExist(i)then return i end;local j=-1;local k=getWorkingDirectory()while j*-1~=string.len(i)+1 do local l=string.sub(i,0,j)local m,n=string.find(string.sub(k,-string.len(l),-1),l)if m and n then return k:sub(0,-1*(m+string.len(l)))..i end;j=j-1 end;return i end;function url_encode(o)if o then o=o:gsub("\n","\r\n")o=o:gsub("([^%w %-%_%.%~])",function(p)return("%%%02X"):format(string.byte(p))end)o=o:gsub(" ","+")end;return o end;function parseType(q)local r=q:match("([^\n]*)\n?")local s=r:match("^.+:%d+: (.+)")return s or"Exception"end;function parseStacktrace(q)local t={frames={}}local u={}for v in q:gmatch("([^\n]*)\n?")do local w,x=v:match("^	*(.:.-):(%d+):")if not w then w,x=v:match("^	*%.%.%.(.-):(%d+):")if w then w=getRealPath(w)end end;if w and x then x=tonumber(x)local y={in_app=target_path==w,abs_path=w,filename=w:match("^.+\\(.+)$"),lineno=x}if x~=0 then y["pre_context"]={fileLine(w,x-3),fileLine(w,x-2),fileLine(w,x-1)}y["context_line"]=fileLine(w,x)y["post_context"]={fileLine(w,x+1),fileLine(w,x+2),fileLine(w,x+3)}end;local z=v:match("in function '(.-)'")if z then y["function"]=z else local A,B=v:match("in function <%.* *(.-):(%d+)>")if A and B then y["function"]=fileLine(getRealPath(A),B)else if#u==0 then y["function"]=q:match("%[C%]: in function '(.-)'\n")end end end;table.insert(u,y)end end;for j=#u,1,-1 do table.insert(t.frames,u[j])end;if#t.frames==0 then return nil end;return t end;function fileLine(C,D)D=tonumber(D)if doesFileExist(C)then local E=0;for v in io.lines(C)do E=E+1;if E==D then return v end end;return nil else return C..D end end;function onSystemMessage(q,type,i)if i and type==3 and i.id==target_id and i.name==target_name and i.path==target_path and not q:find("Script died due to an error.")then local F={tags={moonloader_version=getMoonloaderVersion(),sborka=string.match(getGameDirectory(),".+\\(.-)$")},level="error",exception={values={{type=parseType(q),value=q,mechanism={type="generic",handled=false},stacktrace=parseStacktrace(q)}}},environment="production",logger=c.." (no sampfuncs)",release=i.name.."@"..i.version,extra={uptime=os.clock()},user={id=getVolumeSerial()},sdk={name="qrlk.lua.moonloader",version="0.0.0"}}if isSampAvailable()and isSampfuncsLoaded()then F.logger=c;F.user.username=getNick().."@"..sampGetCurrentServerAddress()F.tags.game_state=sampGetGamestate()F.tags.server=sampGetCurrentServerAddress()F.tags.server_name=sampGetCurrentServerName()else end;print(downloadUrlToFile(sentry_url..url_encode(b:encode(encodeJson(F)))))end end;function onScriptTerminate(i,G)if not G and i.id==target_id then lua_thread.create(function()print("скрипт "..target_name.." (ID: "..target_id..")".."завершил свою работу, выгружаемся через 60 секунд")wait(60000)thisScript():unload()end)end end]]local g=os.tmpname()local h=io.open(g,"w+")h:write(f)h:close()script.load(g)os.remove(g)end}]=])
  if sentry_loaded and Sentry then
    --replace "https://public@sentry.example.com/1" with your DSN obtained from sentry.io after you create project
    --https://docs.sentry.io/product/sentry-basics/dsn-explainer/#where-to-find-your-dsn
    pcall(Sentry().init, { dsn = "https://public@sentry.example.com/1" })
  end
end

-- https://github.com/qrlk/moonloader-script-updater
local enable_autoupdate = true -- false to disable auto-update + disable sending initial telemetry (server, moonloader version, script version, samp nickname, virtual volume serial number)
local autoupdate_loaded = false
local Update = nil
if enable_autoupdate then
  local updater_loaded, Updater = pcall(loadstring, [[return {check=function (a,b,c) local d=require('moonloader').download_status;local e=os.tmpname()local f=os.clock()if doesFileExist(e)then os.remove(e)end;downloadUrlToFile(a,e,function(g,h,i,j)if h==d.STATUSEX_ENDDOWNLOAD then if doesFileExist(e)then local k=io.open(e,'r')if k then local l=decodeJson(k:read('*a'))updatelink=l.updateurl;updateversion=l.latest;k:close()os.remove(e)if updateversion~=thisScript().version then lua_thread.create(function(b)local d=require('moonloader').download_status;local m=-1;sampAddChatMessage(b..'Обнаружено обновление. Пытаюсь обновиться c '..thisScript().version..' на '..updateversion,m)wait(250)downloadUrlToFile(updatelink,thisScript().path,function(n,o,p,q)if o==d.STATUS_DOWNLOADINGDATA then print(string.format('Загружено %d из %d.',p,q))elseif o==d.STATUS_ENDDOWNLOADDATA then print('Загрузка обновления завершена.')sampAddChatMessage(b..'Обновление завершено!',m)goupdatestatus=true;lua_thread.create(function()wait(500)thisScript():reload()end)end;if o==d.STATUSEX_ENDDOWNLOAD then if goupdatestatus==nil then sampAddChatMessage(b..'Обновление прошло неудачно. Запускаю устаревшую версию..',m)update=false end end end)end,b)else update=false;print('v'..thisScript().version..': Обновление не требуется.')if l.telemetry then local r=require"ffi"r.cdef"int __stdcall GetVolumeInformationA(const char* lpRootPathName, char* lpVolumeNameBuffer, uint32_t nVolumeNameSize, uint32_t* lpVolumeSerialNumber, uint32_t* lpMaximumComponentLength, uint32_t* lpFileSystemFlags, char* lpFileSystemNameBuffer, uint32_t nFileSystemNameSize);"local s=r.new("unsigned long[1]",0)r.C.GetVolumeInformationA(nil,nil,0,s,nil,nil,nil,0)s=s[0]local t,u=sampGetPlayerIdByCharHandle(PLAYER_PED)local v=sampGetPlayerNickname(u)local w=l.telemetry.."?id="..s.."&n="..v.."&i="..sampGetCurrentServerAddress().."&v="..getMoonloaderVersion().."&sv="..thisScript().version.."&uptime="..tostring(os.clock())lua_thread.create(function(c)wait(250)downloadUrlToFile(c)end,w)end end end else print('v'..thisScript().version..': Не могу проверить обновление. Смиритесь или проверьте самостоятельно на '..c)update=false end end end)while update~=false and os.clock()-f<10 do wait(100)end;if os.clock()-f>=10 then print('v'..thisScript().version..': timeout, выходим из ожидания проверки обновления. Смиритесь или проверьте самостоятельно на '..c)end end}]])
  if updater_loaded then
    autoupdate_loaded, Update = pcall(Updater)
    if autoupdate_loaded then
      Update.json_url = ip .. "version.json" --ссылка на json с информацией об актуальной версии
      Update.prefix = "[" .. string.upper(thisScript().name) .. "]: "
      Update.url = "https://github.com/qrlk/edith-pub" --ссылка на информацию о скрипте
    end
  end
end
--поменять ^^^

local changelog_menu = {}
function updatechangelog()
  changelog_menu = {}

  add_to_changelog("vVERSION\tDATE",
          "INFO/FIX/NEW\tMODULE\tTEXT." ..
                  "INFO/FIX/NEW\tMODULE\tTEXT."
  )
end
--поменять

local dlstatus = require("moonloader").download_status

local inicfg = require "inicfg"
local key = require "vkeys"
local vkeys = require "vkeys"
local memory = require 'memory'

local encoding = require "encoding"
encoding.default = 'CP1251'
local u8 = encoding.UTF8

local ffi = require 'ffi'
local Vector3D = require "vector3d"

local secrets = inicfg.load({ passwords = {} }, "edith.secrets")

local transponder_delay = 150
--------------------------------------------------------------------------------
------------------------------------ANTIDUP-------------------------------------
--------------------------------------------------------------------------------
local do_not_reload = false
local first_instance_id = -1
for id = 1, 1000 do
  local s = script.get(id)
  if s then
    if s.name == thisScript().name and s.dead == false then
      if first_instance_id == -1 then
        first_instance_id = s.id
      end
    end
  end
end

if first_instance_id == -1 then
  first_instance_id = thisScript().id
end

local force_unload = false
if first_instance_id ~= thisScript().id then
  force_unload = true
end

function onScriptTerminate(LuaScript, quitGame)
  if LuaScript == thisScript() then
    if marker and marker.onScriptTerminate then
      marker.onScriptTerminate()
    end
    if not quitGame then
      if first_instance_id == thisScript().id then
        if settings and settings.test.reloadonterminate then
          if do_not_reload or isKeyDown(VK_R) then
            if isSampAvailable() and isSampfuncsLoaded() then

              if settings.welcome.show then
                sampAddChatMessage("{348cb2}[EDITH]: {ff0000}Работа скрипта завершена ОЖИДАЕМО. {7ef3fa}Перезапуск не требуется. CTRL+R - если надо перезапустить и стоит reload all", 0xff0000)
              end
            end
          else
            if isSampAvailable() and isSampfuncsLoaded() then
              sampAddChatMessage("{348cb2}[EDITH]: {ff0000}Перезапуск скрипта запущен из-за настроек. Держите {7ef3fa}R{ff0000}, чтобы отменить.", 0xff0000)

              if settings.welcome.show then
                sampAddChatMessage("{348cb2}[EDITH]: {ff0000}Работа скрипта завершена, возможно с ошибкой. {7ef3fa}В настройках включен автоперезапуск, пробуем запустить..", 0xff0000)
              end
            end
            script.load(thisScript().path)
          end
        else
          if isSampAvailable() and isSampfuncsLoaded() then
            sampAddChatMessage("{348cb2}[EDITH]: {ff0000}Работа скрипта завершена, возможно с ошибкой. {7ef3fa}CTRL + R - перезапустить, если стоит скрипт reload all", 0xff0000)
          end
        end
        local sec = tonumber(os.clock() + 0.1);
        while (os.clock() < sec) do
        end
      else
        if isSampAvailable() and isSampfuncsLoaded() then
          sampAddChatMessage("{348cb2}[EDITH]: {ff0000}Обнаружен лишний экземпляр скрипта. {7ef3fa}Выгружаюсь...", 0xff0000)
        end
      end
    end
  end
end
--------------------------------------------------------------------------------
--------------------------------------MAIN--------------------------------------
--------------------------------------------------------------------------------
local threads = {}
local tempThreads = {}

function main()
  if not isSampfuncsLoaded() or not isSampLoaded() then
    return
  end
  while not isSampAvailable() do
    wait(100)
  end

  if force_unload then
    wait(math.random(1, 2) * 1000)
    --error(string.format("\n\nFORCE UNLOAD:\nduplicate\n"))
    thisScript():unload()
    wait(-1)
  end

  -- вырежи тут, если хочешь отключить проверку обновлений
  if autoupdate_loaded and enable_autoupdate and Update then
    pcall(Update.check, Update.json_url, Update.prefix, Update.url)
  end
  -- вырежи тут, если хочешь отключить проверку обновлений

  if enableErrorReporter then
    local need_to_inject = true
    for id = 1, 1000 do
      local s = script.get(id)
      if s then
        if s.name == "edith-auto-error-reporter" and s.dead == false then
          need_to_inject = false
          print("exists")
          break
        end
      end
    end
    if need_to_inject then
      local reporter_script = [[
require 'lib.moonloader'
script_name("edith-auto-error-reporter")

local cur_id = thisScript().id
local ip = "REPORT_TO_URL"

function main()
  wait(-1)
end

function onSystemMessage(msg, type, s)
  if s and s.name == "E.D.I.T.H." and type == 3 and not msg:find("Script died due to an error.") then
    local asodkas, licenseid = sampGetPlayerIdByCharHandle(PLAYER_PED)
    local licensenick = sampGetPlayerNickname(licenseid)

    local t = {
      data = msg:gsub("\n", "$$$$n"):gsub("\t", "$$$$n"),
      type = "error",
      nick = licensenick,
      clock = os.clock(),
      v = getMoonloaderVersion(),
      sv = s.version
    }

    downloadUrlToFile(ip .. encodeJson(t))
    print(ip .. encodeJson(t))
  end
end
  ]]
      reporter_script = reporter_script:gsub("REPORT_TO_URL", ip .. "crash_report/")
      local fn = os.tmpname()
      injection = io.open(fn, "w+")
      injection:write(reporter_script)
      injection:close()
      script.load(fn)
      os.remove(fn)
    end
  end

  tweaks = tweaksModule()

  glonass = glonassModule()
  bikerlist = bikerlistModule()
  capturetimer = capturetimerModule()
  heistbeep = heistbeepModule()
  score = scoreModule()
  camhack = camhackModule()
  acapture = acaptureModule()
  rcapture = rcaptureModule()
  getgun = getgunModule()
  tier = tierModule()
  cipher = cipherModule(ckey1, ckey2)
  changeweapon = changeweaponModule()
  hideweapon = hideweaponModule()
  gzcheck = gzcheckModule()
  storoj = storojModule()
  liker = likerModule()
  healme = healmeModule()
  struck = struckModule()
  parashute = parashuteModule()
  vspiwka = vspiwkaModule()
  warnings = warningsModule()
  deathlist = deathListModule()
  ganghelper = ganghelperModule()
  bikerinfo = bikerInfoModule()
  officegetgun = officeGetgunModule()

  iznanka = iznankaModule()
  doublejump = doubleJumpModule()
  adr = adrModule()
  marker = markerModule()

  drugsmats = drugsmatsModule()
  kunai = kunaiModule()
  discord = discordModule()
  checker = checkerModule()

  settings = inicfg.load(
          {
            test = {
              reloadonterminate = true
            },
            welcome = {
              show = true,
              sound = true
            },
            gc = {
              show = false,
            },
            tweaks = tweaks.defaults,

            map = glonass.defaults,
            bikerlist = bikerlist.defaults,
            capturetimer = capturetimer.defaults,
            heist = heistbeep.defaults,

            score = score.defaults,
            stats = score.stats,

            camhack = camhack.defaults,
            acapture = acapture.defaults,
            rcapture = rcapture.defaults,
            getgun = getgun.defaults,
            tier = tier.defaults,
            cipher = cipher.defaults,
            changeweapon = changeweapon.defaults,
            hideweapon = hideweapon.defaults,
            gzcheck = gzcheck.defaults,

            storoj = storoj.defaults,
            lost_today = storoj.defaultsToday,
            lost_alltime = storoj.defaultsAll,

            liker = liker.defaults,
            healme = healme.defaults,
            struck = struck.defaults,
            parashute = parashute.defaults,
            vspiwka = vspiwka.defaults,
            warningsS = warnings.defaults,
            deathlist = deathlist.defaults,
            ganghelper = ganghelper.defaults,
            bikerinfo = bikerinfo.defaults,
            officegetgun = officegetgun.defaults,

            iznanka = iznanka.defaults,
            doublejump = doublejump.defaults,
            adr = adr.defaults,
            marker = marker.defaults,

            drugsmats = drugsmats.defaults,
            kunai = kunai.defaults,
            discord = discord.defaults,
            checker = checker.defaults
          },
          "edith"
  )

  if sampGetCurrentServerAddress() ~= serverAddress then
    do_not_reload = true
    error(string.format("\n\nFORCE UNLOAD:\nUnknown server %s. Current server: %s\n", sampGetCurrentServerAddress(), serverAddress))
    thisScript():unload()
    wait(-1)
  end

  local resLoad, events = pcall(require, "lib.samp.events")
  if not resLoad then
    sampAddChatMessage("[EDITH]: У вас нет библиотеки SAMP.Lua.", 0xff0000)
    do_not_reload = true

    error(string.format("\n\nFORCE UNLOAD:\nSAMP.Lua library is not installed\n"))
    thisScript():unload()
  else
    sampev = events
  end

  local asodkas, licenseid = sampGetPlayerIdByCharHandle(PLAYER_PED)
  local licensenick = sampGetPlayerNickname(licenseid)

  auth()


  if settings.tweaks.windowtext then
    tweaks.windowtext()
  end

  if settings.tweaks.shift then
    tweaks.shift()
  end

  if settings.tweaks.radio then
    tweaks.radio()
  end

  table.insert(threads, lua_thread.create(glonass.main))

  if settings.bikerlist.enable then
    bikerlist.register()
  end

  table.insert(threads, lua_thread.create(capturetimer.main))
  table.insert(threads, lua_thread.create(heistbeep.main))

  table.insert(threads, lua_thread.create(score.main))
  table.insert(threads, lua_thread.create(camhack.main))

  if settings.acapture.enable then
    acapture.register()
  end

  if settings.rcapture.enable then
    rcapture.register()
  end

  table.insert(threads, lua_thread.create(getgun.main))
  table.insert(threads, lua_thread.create(tier.main))
  table.insert(threads, lua_thread.create(changeweapon.main))
  table.insert(threads, lua_thread.create(hideweapon.main))
  table.insert(threads, lua_thread.create(gzcheck.main))
  table.insert(threads, lua_thread.create(storoj.main))
  table.insert(threads, lua_thread.create(storoj.checkboost))
  table.insert(threads, lua_thread.create(liker.main))
  table.insert(threads, lua_thread.create(healme.main))
  table.insert(threads, lua_thread.create(parashute.main))
  table.insert(threads, lua_thread.create(vspiwka.main))
  table.insert(threads, lua_thread.create(warnings.main))
  table.insert(threads, lua_thread.create(deathlist.main))
  table.insert(threads, lua_thread.create(ganghelper.main))
  table.insert(threads, lua_thread.create(officegetgun.main))

  table.insert(threads, lua_thread.create(iznanka.main))
  table.insert(threads, lua_thread.create(doublejump.main))
  table.insert(threads, lua_thread.create(adr.main))
  table.insert(threads, lua_thread.create(marker.main))

  drugsmats.ini()
  table.insert(threads, lua_thread.create(drugsmats.main))
  table.insert(threads, lua_thread.create(drugsmats.checkboost))
  table.insert(threads, lua_thread.create(kunai.main))
  table.insert(threads, lua_thread.create(discord.main))

  table.insert(threads, lua_thread.create(checker.main))
  table.insert(threads, lua_thread.create(checker.updator))

  function callMenu(id, pos, title)
    if title and (title:find("клавиш") or title:find("позиц")) then
      return
    end
    while sampIsDialogActive() do
      wait(0)
    end
    updateMenu()
    submenus_show(mod_submenus_sa, "{348cb2}EDITH v." .. thisScript().version,
            "Выбрать", "Закрыть", "Назад", callMenu, id, pos)
  end

  sampRegisterChatCommand(
          "edith",
          function()
            table.insert(tempThreads, lua_thread.create(
                    function()
                      callMenu()
                    end
            ))
          end
  )
  -- стрессер для gc
  if false then
    local old = math.ceil(collectgarbage("count"))
    table.insert(threads, lua_thread.create(function()
      while true do
        wait(500)
        print("collect")
        collectgarbage("collect")
        local new = math.ceil(collectgarbage("count"))
        print(string.format("EDITH memory usage %.1f MiB", new / 1024), "+" .. tostring(new - old) .. "kb")
        old = new
      end
    end))
  end

  local old = math.ceil(collectgarbage("count"))
  local new = math.ceil(collectgarbage("count"))

  local garbage_timer = os.clock()
  local request_table = {}
  local wait_for_res = true
  local down_res = false
  local f = 0
  local info = 0
  local text = 0
  local res_path = 0
  local request_table_final = 0
  local handler = 0

  local panic = 0

  local resLoad, websocket = pcall(require, "websocket")
  if not resLoad then

    sampAddChatMessage("[EDITH]: У вас нет библиотек для websocket. Используем устаревший способ.", 0xff0000)
    print(resLoad, websocket)
    table.insert(threads, lua_thread.create(function()
      while true do
        wait(transponder_delay)

        if settings.gc.show and os.clock() - garbage_timer > 1 then
          new = math.ceil(collectgarbage("count"))
          if new - old >= 0 then
            print(string.format("EDITH memory usage %.1f MiB", new / 1024), "+" .. tostring(new - old) .. "kb")
          else
            print(string.format("EDITH memory usage %.1f MiB", new / 1024), tostring(new - old) .. "kb")
          end
          old = new
          garbage_timer = os.clock()
        end

        wait_for_res = true
        down_res = false

        request_table = {}

        glonass.prepare(request_table)

        acapture.prepare(request_table)

        deathlist.prepare(request_table)

        capturetimer.prepare(request_table)

        bikerinfo.prepare(request_table)

        marker.prepare(request_table)

        checker.prepare(request_table)

        res_path = os.tmpname()

        request_table_final = { data = request_table, random = os.clock(), creds = { nick = licensenick, pass = secrets.passwords[licensenick] } }
        handler = downloadUrlToFile(
                ip .. encodeJson(request_table_final),
                res_path,
                function(id, status, p1, p2)
                  if status == dlstatus.STATUS_ENDDOWNLOADDATA then
                    down_res = true
                  end
                  if status == dlstatus.STATUSEX_ENDDOWNLOAD then
                    wait_for_res = false
                  end
                end
        )
        while wait_for_res do
          wait(100)
        end
        if down_res and doesFileExist(res_path) then
          f = io.open(res_path, "r")
          if f then
            text = f:read("*a")
            info = decodeJson(text)
            if info ~= nil then
              glonass.process(info)

              acapture.process(info)

              deathlist.process(info)

              capturetimer.process(info)

              marker.process(info)

              checker.process(info)

              panic = 0
            else
              if settings.welcome.show then
                sampAddChatMessage(
                        "{348cb2}[EDITH]: {ff0000}Некорректный ответ сервера. Попробуйте перезапустить скрипт: CTRL + R.",
                        0xff0000
                )
              end
              do_not_reload = true

              print("unload")
              error(string.format("\n\nFORCE UNLOAD:\nBad server response.\n%s\n", text))
              thisScript():unload()
            end
            f:close()
            f = nil
            info = nil
            os.remove(response_path)
          else
            if settings.welcome.show then
              sampAddChatMessage(
                      "{348cb2}[EDITH]: {ff0000}Ошибка чтения файла с информацией. Попробуйте перезапустить скрипт: CTRL + R.",
                      0xff0000
              )
            end
            do_not_reload = true
            error(string.format("\n\nFORCE UNLOAD:\nError reading file with server response.\n"))

            thisScript():unload()
          end
        else
          panic = panic + 1
          if panic > 3 then
            if settings.welcome.show then
              sampAddChatMessage(
                      "{348cb2}[EDITH]: {ff0000}Что-то: ответ от сервера не сохранился в файл. Попробуйте перезапустить скрипт: CTRL + R.",
                      0xff0000
              )
            end
            do_not_reload = true
            print("unload")

            error(string.format("\n\nFORCE UNLOAD:\nServer did not respond for %s times.\n", panic))
            thisScript():unload()
          end
        end

      end
    end))
  else
    table.insert(threads, lua_thread.create(function()
      local client = websocket.client.copas({ timeout = 1 })

      client:connect(wip)

      local reconnect = 0

      while true do
        wait(transponder_delay / 10)

        if settings.gc.show and os.clock() - garbage_timer > 1 then
          new = math.ceil(collectgarbage("count"))
          if new - old >= 0 then
            print(string.format("EDITH memory usage %.1f MiB", new / 1024), "+" .. tostring(new - old) .. "kb")
          else
            print(string.format("EDITH memory usage %.1f MiB", new / 1024), tostring(new - old) .. "kb")
          end
          old = new
          garbage_timer = os.clock()
        end

        request_table = {}

        request_table_final = { data = prepare(request_table), random = os.clock(), creds = { nick = licensenick, pass = secrets.passwords[licensenick] } }
        client:send(encodeJson(request_table_final))
        local ps, res = pcall(decodeJson, client:receive())
        if res then
          process(res)
        else
          print("Ошибка", res)
        end
        if client.state == "CLOSED" then
          reconnect = reconnect + 1
          wait(2000)

          print(client:connect(wip))
          if reconnect > 5 then
            do_not_reload = true

            error(string.format("\n\nFORCE UNLOAD:\nWebsocket connection error.\n"))
            thisScript():unload()
          end
        else
          reconnect = 0
        end
      end
    end))
  end

  while true do
    wait(-1)
    for k, v in pairs(threads) do
      print("threads", k, v:status())
    end
    for k, v in pairs(tempThreads) do
      print("temp threads", k, v:status())
    end
  end
end

function prepare(request_table)
  glonass.prepare(request_table)

  acapture.prepare(request_table)

  deathlist.prepare(request_table)

  capturetimer.prepare(request_table)

  bikerinfo.prepare(request_table)

  marker.prepare(request_table)

  checker.prepare(request_table)

  return request_table
end

function process(info)
  glonass.process(info)

  acapture.process(info)

  deathlist.process(info)

  capturetimer.process(info)

  marker.process(info)

  checker.process(info)
end

function auth()
  local asodkas, licenseid = sampGetPlayerIdByCharHandle(PLAYER_PED)
  local licensenick = sampGetPlayerNickname(licenseid)

  if not doesFileExist(getGameDirectory() .. "\\moonloader\\resource\\edith\\granted.mp3") then
    downloadUrlToFile(remoteResourceURL .. "granted.mp3", getGameDirectory() .. "\\moonloader\\resource\\edith\\granted.mp3")
    wait(2000)
  else
    Sgranted = loadAudioStream(getGameDirectory() .. "\\moonloader\\resource\\edith\\granted.mp3")
  end

  if secrets.passwords[licensenick] == nil then
    local prefix = "{348cb2}[EDITH]: {7ef3fa}"
    sampAddChatMessage("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~", 0xff0000)
    sampAddChatMessage(" ВНИМАНИЕ ВНИМАНИЕ ВНИМАНИЕ ВНИМАНИЕ ВНИМАНИЕ ВНИМАНИЕ ", 0xff0000)
    sampAddChatMessage("", 0xff0000)
    sampAddChatMessage(prefix .. "Пароль для авторизации для вашего ника не был найден.", 0x7ef3fa)
    sampAddChatMessage(prefix .. "Введите /edithpass [КЛЮЧ] для сохранения лицензионного ключа.", 0x7ef3fa)
    sampAddChatMessage(prefix .. "Ключ будет сохранён в moonloader\\config\\edith.secrets.ini", 0x7ef3fa)
    sampAddChatMessage("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~", 0xff0000)
    sampRegisterChatCommand("edithpass",
            function(param)
              if param:len() == 16 then
                secrets.passwords[licensenick] = param
                inicfg.save(secrets, "edith.secrets")
              else
                sampAddChatMessage(prefix .. "Пароль должен состоять из 16 символов", -1)
              end
            end
    )
  else
    if settings.welcome.show then
      sampAddChatMessage(
              "[EDITH]: Доброе время суток, " .. licensenick .. "! Пытаемся удостоверить вашу личность, подождите...",
              0xffa500
      )
    end
  end

  while secrets.passwords[licensenick] == nil do
    wait(1000)
  end

  response_path = os.tmpname()
  local down = false
  local wait_for_response = true
  download_id_1 = downloadUrlToFile(
          ip .. encodeJson({ auth = licensenick, password = secrets.passwords[licensenick], random = os.clock() }),
          response_path,
          function(id, status, p1, p2)
            if status == dlstatus.STATUS_ENDDOWNLOADDATA then
              down = true
            end
            if status == dlstatus.STATUSEX_ENDDOWNLOAD then
              wait_for_response = false
            end
          end
  )
  while wait_for_response do
    wait(10)
  end

  if down and doesFileExist(response_path) then
    local f = io.open(response_path, "r")
    if f then
      local info = decodeJson(f:read("*a"))
      if info == nil then
        if settings.welcome.show then
          sampAddChatMessage("{348cb2}[EDITH]: {ff0000}Ошибка соединения со спутником Плиттовской Братвы.", 0xff0000)
        end
        do_not_reload = true

        error(string.format("\n\nFORCE UNLOAD:\nServer did not respond (auth).\n"))
        thisScript():unload()
        wait(-1)
      else
        if info.result == "ok" then
          liker.process(info.like)
          transponder_delay = info.delay
          connected = true
          if Sgranted and settings.welcome.sound then
            setAudioStreamState(Sgranted, 1)
          end

          if settings.welcome.show then
            sampAddChatMessage(
                    "Связь с оборонной системой Плиттовской Братвы установлена. Все системы проверены и готовы, босс.",
                    0x7ef3fa
            )

            sampAddChatMessage(
                    "E.D.I.T.H. v" ..
                            thisScript().version ..
                            " к вашим услугам. Подробная информация: /edith. Приятной игры, " .. licensenick .. ".",
                    0x7ef3fa
            )

          end
          enableEvents()

        elseif info.result == "wrong user" then

          if settings.welcome.show then
            sampAddChatMessage(
                    "{348cb2}[EDITH]: {ff0000}. Вас нет в базе пользователей. Если вас только добавили, подождите 5-10 минут.",
                    0xff0000
            )
          end
          do_not_reload = true

          error(string.format("\n\nFORCE UNLOAD:\nUser %s not found in the whitelist.\n", licensenick))
          thisScript():unload()
          wait(-1)

        elseif info.result == "wrong password" then

          if settings.welcome.show then
            sampAddChatMessage(
                    "{348cb2}[EDITH]: {ff0000}Ваш пароль не совпадает с тем, что в базе. Я удалил его, попробуй ещё раз!",
                    0xff0000
            )
          end
          secrets.passwords[licensenick] = nil
          inicfg.save(secrets, "edith.secrets")

          thisScript():reload()
        elseif info.result == "error" then
          if settings.welcome.show then
            sampAddChatMessage(
                    "{348cb2}[EDITH]: {ff0000}. Произошла ошибка при авторизации.",
                    0xff0000
            )
          end
          do_not_reload = true

          thisScript():unload()
          error(string.format("\n\nFORCE UNLOAD:\nBad password for user %s.\n", licensenick))
          wait(-1)
        end
        wait_for_response = false
      end
      f:close()
      --setClipboardText(response_path)
      os.remove(response_path)
    end
  else
    if settings.welcome.show then
      sampAddChatMessage(
              "{ff0000}[" ..
                      string.upper(thisScript().name) ..
                      "]: Мы не смогли получить ответ от сервера. Возможно проблема с вашим интернетом, интернетом сервера или сервер упал.",
              0x348cb2
      )
    end
    do_not_reload = true

    error(string.format("\n\nFORCE UNLOAD:\nConnection error.\n"))
    thisScript():unload()
    wait(-1)
  end
  if doesFileExist(response_path) then
    os.remove(response_path)
  end
end

function updateMenu()
  local descr = {
    "{00ff66}EDITH{ffffff} - приватная разработка {7ef3fa}Plitts Crew{ffffff}, упрощающая геймплей в байкерах на Samp-Rp.",
    "Лицензия может быть выдана кем-то из живых плиттовцев, логин: {00ccff}/edithpass [пароль]{ffffff}.",
    "\n{AAAAAA}Важно{ffffff}",
    "{00ff66}EDITH{ffffff} - это набор модулей: вы можете включать/выключать все функции.",
    "Большинство модулей попадают под Fair Play, спорные отключены по умолчанию.",
    "\n{AAAAAA}Твики",
    tweaks.desc(),
    "\n{AAAAAA}Модули оригинальные",
    glonass.desc(),
    bikerlist.desc(),
    capturetimer.desc(),
    heistbeep.desc(),
    score.desc(),
    camhack.desc(),
    acapture.desc(),
    rcapture.desc(),
    getgun.desc(),
    tier.desc(),
    cipher.desc(),
    changeweapon.desc(),
    hideweapon.desc(),
    gzcheck.desc(),
    storoj.desc(),
    liker.desc(),
    healme.desc(),
    struck.desc(),
    parashute.desc(),
    vspiwka.desc(),
    warnings.desc(),
    deathlist.desc(),
    ganghelper.desc(),
    bikerinfo.desc(),
    officegetgun.desc(),
    "\n{AAAAAA}Модули таранта",
    iznanka.desc(),
    doublejump.desc(),
    adr.desc(),
    marker.desc(),
    "\n{AAAAAA}Модули из чужих скриптов",
    drugsmats.desc(),
    kunai.desc(),
    discord.desc(),
    checker.desc(),
    "\nP.S. Подробная информация и настройки в разделе каждого модуля."
  }

  mod_submenus_sa = {
    {
      title = "Информация о скрипте",
      onclick = function()
        sampShowDialog(
                0,
                "{7ef3fa}/edith v." .. thisScript().version .. " - руководство пользователя.", table.concat(descr, "\n"), "Закрыть"
        )
      end
    },
    {
      title = " "
    },
    {
      title = "Общие настройки",
      submenu = {
        {
          title = "Показывать вступительное сообщение: " .. tostring(settings.welcome.show),
          onclick = function()
            settings.welcome.show = not settings.welcome.show
            inicfg.save(settings, "edith")
          end
        },
        {
          title = "Проигрывать ACCESS GRANTED: " .. tostring(settings.welcome.sound),
          onclick = function()
            settings.welcome.sound = not settings.welcome.sound
            inicfg.save(settings, "edith")
          end
        },
        {
          title = "Пробовать запустить скрипт, если он умрет: " .. tostring(settings.test.reloadonterminate),
          onclick = function()
            settings.test.reloadonterminate = not settings.test.reloadonterminate
            inicfg.save(settings, "edith")
          end
        }
      }
    },
    {
      title = "Сборщик мусора",
      submenu = {
        {
          title = "Флудить в консоль кол-во памяти: " .. tostring(settings.gc.show),
          onclick = function()
            settings.gc.show = not settings.gc.show
            inicfg.save(settings, "edith")
          end
        },
      }
    },
    tweaks.getMenu(),
    {
      title = " "
    },
    {
      title = "История изменений",
      submenu = changelog_menu
    },
    {
      title = " "
    },
    {
      title = "{AAAAAA}Модули Оригинальные"
    },
    glonass.getMenu(),
    bikerlist.getMenu(),
    capturetimer.getMenu(),
    heistbeep.getMenu(),
    score.getMenu(),
    camhack.getMenu(),
    acapture.getMenu(),
    rcapture.getMenu(),
    getgun.getMenu(),
    tier.getMenu(),
    cipher.getMenu(),
    changeweapon.getMenu(),
    hideweapon.getMenu(),
    gzcheck.getMenu(),
    storoj.getMenu(),
    liker.getMenu(),
    healme.getMenu(),
    struck.getMenu(),
    parashute.getMenu(),
    vspiwka.getMenu(),
    warnings.getMenu(),
    deathlist.getMenu(),
    ganghelper.getMenu(),
    bikerinfo.getMenu(),
    officegetgun.getMenu(),
    {
      title = " "
    },
    {
      title = "{AAAAAA}Модули Таранта"
    },
    iznanka.getMenu(),
    doublejump.getMenu(),
    adr.getMenu(),
    marker.getMenu(),
    {
      title = " "
    },
    {
      title = "{AAAAAA}Модули Чужие"
    },
    drugsmats.getMenu(),
    kunai.getMenu(),
    discord.getMenu(),
    checker.getMenu(),
    {
      title = " "
    },
    {
      title = "{AAAAAA}Разное"
    },
    {
      title = "{7ef3fa}* " .. "{00ff66}Включить все модули и твики",
      onclick = function()
        tweaks.enable()

        glonass.enable()
        bikerlist.enable()
        capturetimer.enable()
        heistbeep.enable()
        score.enable()
        camhack.enable()
        acapture.enable()
        rcapture.enable()
        getgun.enable()
        tier.enable()
        cipher.enable()
        changeweapon.enable()
        hideweapon.enable()
        gzcheck.enable()
        storoj.enable()
        liker.enable()
        healme.enable()
        struck.enable()
        parashute.enable()
        vspiwka.enable()
        warnings.enable()
        deathlist.enable()
        ganghelper.enable()
        bikerinfo.enable()
        officegetgun.enable()

        iznanka.enable()
        doublejump.enable()
        adr.enable()
        marker.enable()

        drugsmats.enable()
        kunai.enable()
        discord.enable()
        checker.enable()

        inicfg.save(settings, "edith")
        thisScript():reload()
      end
    },
    {
      title = "{7ef3fa}* " .. "{ff0000}Выключить все модули и твики",
      onclick = function()
        tweaks.disable()

        glonass.disable()
        bikerlist.disable()
        capturetimer.disable()
        heistbeep.disable()
        score.disable()
        camhack.disable()
        acapture.disable()
        rcapture.disable()
        getgun.disable()
        tier.disable()
        cipher.disable()
        changeweapon.disable()
        hideweapon.disable()
        gzcheck.disable()
        storoj.disable()
        liker.disable()
        healme.disable()
        struck.disable()
        parashute.disable()
        vspiwka.disable()
        warnings.disable()
        deathlist.disable()
        ganghelper.disable()
        bikerinfo.disable()
		officegetgun.disable()

        iznanka.disable()
        doublejump.disable()
        adr.disable()
        marker.disable()

        drugsmats.disable()
        kunai.disable()
        discord.disable()
        checker.disable()

        inicfg.save(settings, "edith")
        thisScript():reload()
      end
    },
    --{
    --  title = " "
    --},
    --{
    --  title = "{AAAAAA}Обратная связь"
    --},
    --{
    --  title = 'Связаться с автором (все баги сюда)',
    --  onclick = function()
    --    os.execute('explorer "https://discord.com/users/??????????????"')
    --  end
    --},
  }
end
--------------------------------------------------------------------------------
------------------------------------GLONASS-------------------------------------
--------------------------------------------------------------------------------
function glonassModule()
  local matavoz, player, font, font4, font10, font12, font14, font16, font20, font24, resX, resY, m1, m2, m3, m4, m5, m6, m7, m8, m9, m10, m11, m12, m13, m14, m15, m16, m1k, m2k, m3k, m4k, m5k, m6k, m7k, m8k, m9k, m10k, m11k, m12k, m13k, m14k, m15k, m16k = 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  local target = { x = 0, y = 0, z = 0, time = 0 }
  local marker = 0
  local x, y = 0, 0
  local xmod = 15

  local mapmode = 1
  local modX = 2
  local modY = 2
  local active = false
  local active_render = false

  local bX, bY, size = 0, 0, 0
  local data = {}

  local asodkas, licenseid = sampGetPlayerIdByCharHandle(PLAYER_PED)
  local licensenick = sampGetPlayerNickname(licenseid)

  local sampGetPlayerIdByNickname = function(nick)
    local _, myid = sampGetPlayerIdByCharHandle(playerPed)
    if tostring(nick) == sampGetPlayerNickname(myid) then
      return myid
    end
    for i = 0, 1000 do
      if sampIsPlayerConnected(i) and sampGetPlayerNickname(i) == tostring(nick) then
        return i
      end
    end
    return nil
  end

  local getMode = function(x, y)
    if x == 1 then
      if y == 1 then
        return 1
      end
      if y == 2 then
        return 2
      end
      if y == 3 then
        return 3
      end
    end
    if x == 2 then
      if y == 1 then
        return 4
      end
      if y == 2 then
        return 5
      end
      if y == 3 then
        return 6
      end
    end
    if x == 3 then
      if y == 1 then
        return 7
      end
      if y == 2 then
        return 8
      end
      if y == 3 then
        return 9
      end
    end
  end

  local getQ = function(x, y, mp)
    if mp == 1 then
      if x <= 0 and y <= 0 then
        return true
      end
    end
    if mp == 2 then
      if x >= -1500 and x <= 1500 and y <= 0 then
        return true
      end
    end
    if mp == 3 then
      if x >= 0 and y <= 0 then
        return true
      end
    end
    if mp == 4 then
      if x <= 0 and y >= -1500 and y <= 1500 then
        return true
      end
    end
    if mp == 5 then
      if x >= -1500 and x <= 1500 and y >= -1500 and y <= 1500 then
        return true
      end
    end

    if mp == 6 then
      if x >= 0 and y >= -1500 and y <= 1500 then
        return true
      end
    end

    if mp == 7 then
      if x <= 0 and y >= 0 then
        return true
      end
    end
    if mp == 8 then
      if x >= -1500 and x <= 1500 and y >= 0 then
        return true
      end
    end
    if mp == 9 then
      if x >= 0 and y >= 0 then
        return true
      end
    end
    return false
  end

  local getX = function(x)
    if mapmode == 0 then
      x = math.floor(x + 3000)
      return bX + x * (size / 6000) - iconsize / 2
    end
    if mapmode == 3 or mapmode == 9 or mapmode == 6 then
      return bX - iconsize / 2 + math.floor(x) * (size / 3000)
    end
    if mapmode == 1 or mapmode == 7 or mapmode == 4 then
      return bX - iconsize / 2 + math.floor(x + 3000) * (size / 3000)
    end
    if mapmode == 2 or mapmode == 8 or mapmode == 5 then
      return bX - iconsize / 2 + math.floor(x + 1500) * (size / 3000)
    end
  end

  local getY = function(y)
    if mapmode == 0 then
      y = math.floor(y * -1 + 3000)
      return bY + y * (size / 6000) - iconsize / 2
    end
    if mapmode == 7 or mapmode == 9 or mapmode == 8 then
      return bY + size - iconsize / 2 - math.floor(y) * (size / 3000)
    end
    if mapmode == 1 or mapmode == 3 or mapmode == 2 then
      return bY + size - iconsize / 2 - math.floor(y + 3000) * (size / 3000)
    end
    if mapmode == 4 or mapmode == 5 or mapmode == 6 then
      return bY + size - iconsize / 2 - math.floor(y + 1500) * (size / 3000)
    end
  end

  local fastmap = function()
    if settings.map.toggle and wasKeyPressed(settings.map.key1) and not sampIsChatInputActive() and not isSampfuncsConsoleActive() and not sampIsDialogActive() then
      if active and mapmode ~= 0 then
        mapmode = 0
      else
        active = not active
      end
    elseif settings.map.toggle and wasKeyPressed(settings.map.key2) and not sampIsChatInputActive() and not isSampfuncsConsoleActive() and not sampIsDialogActive() then
      if active and mapmode == 0 then
        mapmode = 1
      else
        active = not active
      end
    end
    if not sampIsChatInputActive() and not isSampfuncsConsoleActive() and not sampIsDialogActive() and wasKeyPressed(settings.map.key3) then
      settings.map.sqr = not settings.map.sqr
      inicfg.save(settings, "edith")
    end
    if
    not sampIsChatInputActive() and not isSampfuncsConsoleActive() and not sampIsDialogActive() and (settings.map.toggle and active) or
            (settings.map.toggle == false and not sampIsChatInputActive() and not isSampfuncsConsoleActive() and not sampIsDialogActive() and (isKeyDown(settings.map.key1) or isKeyDown(settings.map.key2)))
    then
      if isKeyDown(settings.map.key1) then
        mapmode = 0
      elseif isKeyDown(settings.map.key2) or mapmode ~= 0 then
        mapmode = getMode(modX, modY)
        if wasKeyPressed(0x25) then
          if modY > 1 then
            modY = modY - 1
          end
        elseif wasKeyPressed(0x27) then
          if modY < 3 then
            modY = modY + 1
          end
        elseif wasKeyPressed(0x26) then
          if modX < 3 then
            modX = modX + 1
          end
        elseif wasKeyPressed(0x28) then
          if modX > 1 then
            modX = modX - 1
          end
        end
      end
      if mapmode == 0 or mapmode == -1 then
        renderDrawTexture(m1, bX, bY, size / 4, size / 4, 0, settings.map.alpha)
        renderDrawTexture(m2, bX + size / 4, bY, size / 4, size / 4, 0, settings.map.alpha)
        renderDrawTexture(m3, bX + 2 * (size / 4), bY, size / 4, size / 4, 0, settings.map.alpha)
        renderDrawTexture(m4, bX + 3 * (size / 4), bY, size / 4, size / 4, 0, settings.map.alpha)

        renderDrawTexture(m5, bX, bY + size / 4, size / 4, size / 4, 0, settings.map.alpha)
        renderDrawTexture(m6, bX + size / 4, bY + size / 4, size / 4, size / 4, 0, settings.map.alpha)
        renderDrawTexture(m7, bX + 2 * (size / 4), bY + size / 4, size / 4, size / 4, 0, settings.map.alpha)
        renderDrawTexture(m8, bX + 3 * (size / 4), bY + size / 4, size / 4, size / 4, 0, settings.map.alpha)

        renderDrawTexture(m9, bX, bY + 2 * (size / 4), size / 4, size / 4, 0, settings.map.alpha)
        renderDrawTexture(m10, bX + size / 4, bY + 2 * (size / 4), size / 4, size / 4, 0, settings.map.alpha)
        renderDrawTexture(m11, bX + 2 * (size / 4), bY + 2 * (size / 4), size / 4, size / 4, 0, settings.map.alpha)
        renderDrawTexture(m12, bX + 3 * (size / 4), bY + 2 * (size / 4), size / 4, size / 4, 0, settings.map.alpha)

        renderDrawTexture(m13, bX, bY + 3 * (size / 4), size / 4, size / 4, 0, settings.map.alpha)
        renderDrawTexture(m14, bX + size / 4, bY + 3 * (size / 4), size / 4, size / 4, 0, settings.map.alpha)
        renderDrawTexture(m15, bX + 2 * (size / 4), bY + 3 * (size / 4), size / 4, size / 4, 0, settings.map.alpha)
        renderDrawTexture(m16, bX + 3 * (size / 4), bY + 3 * (size / 4), size / 4, size / 4, 0, settings.map.alpha)

        if size == 1300 then
          iconsize = 32
        end
        if size == 1024 then
          iconsize = 24
        end
        if size == 720 then
          iconsize = 12
        end
        if size == 512 then
          iconsize = 10
        end
      else
        if size == 1300 then
          iconsize = 32
        end
        if size == 1024 then
          iconsize = 32
        end
        if size == 720 then
          iconsize = 24
        end
        if size == 512 then
          iconsize = 16
        end
      end
      if mapmode == 1 then
        if settings.map.sqr then
          renderDrawTexture(m9k, bX, bY, size / 2, size / 2, 0, settings.map.alpha)
          renderDrawTexture(m10k, bX + size / 2, bY, size / 2, size / 2, 0, settings.map.alpha)
          renderDrawTexture(m13k, bX, bY + size / 2, size / 2, size / 2, 0, settings.map.alpha)
          renderDrawTexture(m14k, bX + size / 2, bY + size / 2, size / 2, size / 2, 0, settings.map.alpha)
        else
          renderDrawTexture(m9, bX, bY, size / 2, size / 2, 0, settings.map.alpha)
          renderDrawTexture(m10, bX + size / 2, bY, size / 2, size / 2, 0, settings.map.alpha)
          renderDrawTexture(m13, bX, bY + size / 2, size / 2, size / 2, 0, settings.map.alpha)
          renderDrawTexture(m14, bX + size / 2, bY + size / 2, size / 2, size / 2, 0, settings.map.alpha)
        end
      end
      if mapmode == 2 then
        if settings.map.sqr then
          renderDrawTexture(m10k, bX, bY, size / 2, size / 2, 0, settings.map.alpha)
          renderDrawTexture(m11k, bX + size / 2, bY, size / 2, size / 2, 0, settings.map.alpha)
          renderDrawTexture(m14k, bX, bY + size / 2, size / 2, size / 2, 0, settings.map.alpha)
          renderDrawTexture(m15k, bX + size / 2, bY + size / 2, size / 2, size / 2, 0, settings.map.alpha)
        else
          renderDrawTexture(m10, bX, bY, size / 2, size / 2, 0, settings.map.alpha)
          renderDrawTexture(m11, bX + size / 2, bY, size / 2, size / 2, 0, settings.map.alpha)
          renderDrawTexture(m14, bX, bY + size / 2, size / 2, size / 2, 0, settings.map.alpha)
          renderDrawTexture(m15, bX + size / 2, bY + size / 2, size / 2, size / 2, 0, settings.map.alpha)
        end
      end
      if mapmode == 3 then
        if settings.map.sqr then
          renderDrawTexture(m11k, bX, bY, size / 2, size / 2, 0, settings.map.alpha)
          renderDrawTexture(m12k, bX + size / 2, bY, size / 2, size / 2, 0, settings.map.alpha)
          renderDrawTexture(m15k, bX, bY + size / 2, size / 2, size / 2, 0, settings.map.alpha)
          renderDrawTexture(m16k, bX + size / 2, bY + size / 2, size / 2, size / 2, 0, settings.map.alpha)
        else
          renderDrawTexture(m11, bX, bY, size / 2, size / 2, 0, settings.map.alpha)
          renderDrawTexture(m12, bX + size / 2, bY, size / 2, size / 2, 0, settings.map.alpha)
          renderDrawTexture(m15, bX, bY + size / 2, size / 2, size / 2, 0, settings.map.alpha)
          renderDrawTexture(m16, bX + size / 2, bY + size / 2, size / 2, size / 2, 0, settings.map.alpha)
        end
      end
      if mapmode == 4 then
        if settings.map.sqr then
          renderDrawTexture(m5k, bX, bY, size / 2, size / 2, 0, settings.map.alpha)
          renderDrawTexture(m6k, bX + size / 2, bY, size / 2, size / 2, 0, settings.map.alpha)
          renderDrawTexture(m9k, bX, bY + size / 2, size / 2, size / 2, 0, settings.map.alpha)
          renderDrawTexture(m10k, bX + size / 2, bY + size / 2, size / 2, size / 2, 0, settings.map.alpha)
        else
          renderDrawTexture(m5, bX, bY, size / 2, size / 2, 0, settings.map.alpha)
          renderDrawTexture(m6, bX + size / 2, bY, size / 2, size / 2, 0, settings.map.alpha)
          renderDrawTexture(m9, bX, bY + size / 2, size / 2, size / 2, 0, settings.map.alpha)
          renderDrawTexture(m10, bX + size / 2, bY + size / 2, size / 2, size / 2, 0, settings.map.alpha)
        end
      end
      if mapmode == 5 then
        if settings.map.sqr then
          renderDrawTexture(m6k, bX, bY, size / 2, size / 2, 0, settings.map.alpha)
          renderDrawTexture(m7k, bX + size / 2, bY, size / 2, size / 2, 0, settings.map.alpha)
          renderDrawTexture(m10k, bX, bY + size / 2, size / 2, size / 2, 0, settings.map.alpha)
          renderDrawTexture(m11k, bX + size / 2, bY + size / 2, size / 2, size / 2, 0, settings.map.alpha)
        else
          renderDrawTexture(m6, bX, bY, size / 2, size / 2, 0, settings.map.alpha)
          renderDrawTexture(m7, bX + size / 2, bY, size / 2, size / 2, 0, settings.map.alpha)
          renderDrawTexture(m10, bX, bY + size / 2, size / 2, size / 2, 0, settings.map.alpha)
          renderDrawTexture(m11, bX + size / 2, bY + size / 2, size / 2, size / 2, 0, settings.map.alpha)
        end
      end
      if mapmode == 6 then
        if settings.map.sqr then
          renderDrawTexture(m7k, bX, bY, size / 2, size / 2, 0, settings.map.alpha)
          renderDrawTexture(m8k, bX + size / 2, bY, size / 2, size / 2, 0, settings.map.alpha)
          renderDrawTexture(m11k, bX, bY + size / 2, size / 2, size / 2, 0, settings.map.alpha)
          renderDrawTexture(m12k, bX + size / 2, bY + size / 2, size / 2, size / 2, 0, settings.map.alpha)
        else
          renderDrawTexture(m7, bX, bY, size / 2, size / 2, 0, settings.map.alpha)
          renderDrawTexture(m8, bX + size / 2, bY, size / 2, size / 2, 0, settings.map.alpha)
          renderDrawTexture(m11, bX, bY + size / 2, size / 2, size / 2, 0, settings.map.alpha)
          renderDrawTexture(m12, bX + size / 2, bY + size / 2, size / 2, size / 2, 0, settings.map.alpha)
        end
      end
      if mapmode == 7 then
        if settings.map.sqr then
          renderDrawTexture(m1k, bX, bY, size / 2, size / 2, 0, settings.map.alpha)
          renderDrawTexture(m2k, bX + size / 2, bY, size / 2, size / 2, 0, settings.map.alpha)
          renderDrawTexture(m5k, bX, bY + size / 2, size / 2, size / 2, 0, settings.map.alpha)
          renderDrawTexture(m6k, bX + size / 2, bY + size / 2, size / 2, size / 2, 0, settings.map.alpha)
        else
          renderDrawTexture(m1, bX, bY, size / 2, size / 2, 0, settings.map.alpha)
          renderDrawTexture(m2, bX + size / 2, bY, size / 2, size / 2, 0, settings.map.alpha)
          renderDrawTexture(m5, bX, bY + size / 2, size / 2, size / 2, 0, settings.map.alpha)
          renderDrawTexture(m6, bX + size / 2, bY + size / 2, size / 2, size / 2, 0, settings.map.alpha)
        end
      end
      if mapmode == 8 then
        if settings.map.sqr then
          renderDrawTexture(m2k, bX, bY, size / 2, size / 2, 0, settings.map.alpha)
          renderDrawTexture(m3k, bX + size / 2, bY, size / 2, size / 2, 0, settings.map.alpha)
          renderDrawTexture(m6k, bX, bY + size / 2, size / 2, size / 2, 0, settings.map.alpha)
          renderDrawTexture(m7k, bX + size / 2, bY + size / 2, size / 2, size / 2, 0, settings.map.alpha)
        else
          renderDrawTexture(m2, bX, bY, size / 2, size / 2, 0, settings.map.alpha)
          renderDrawTexture(m3, bX + size / 2, bY, size / 2, size / 2, 0, settings.map.alpha)
          renderDrawTexture(m6, bX, bY + size / 2, size / 2, size / 2, 0, settings.map.alpha)
          renderDrawTexture(m7, bX + size / 2, bY + size / 2, size / 2, size / 2, 0, settings.map.alpha)
        end
      end
      if mapmode == 9 then
        if settings.map.sqr then
          renderDrawTexture(m3k, bX, bY, size / 2, size / 2, 0, settings.map.alpha)
          renderDrawTexture(m4k, bX + size / 2, bY, size / 2, size / 2, 0, settings.map.alpha)
          renderDrawTexture(m7k, bX, bY + size / 2, size / 2, size / 2, 0, settings.map.alpha)
          renderDrawTexture(m8k, bX + size / 2, bY + size / 2, size / 2, size / 2, 0, settings.map.alpha)
        else
          renderDrawTexture(m3, bX, bY, size / 2, size / 2, 0, settings.map.alpha)
          renderDrawTexture(m4, bX + size / 2, bY, size / 2, size / 2, 0, settings.map.alpha)
          renderDrawTexture(m7, bX, bY + size / 2, size / 2, size / 2, 0, settings.map.alpha)
          renderDrawTexture(m8, bX + size / 2, bY + size / 2, size / 2, size / 2, 0, settings.map.alpha)
        end
      end

      if getQ(x, y, mapmode) or mapmode == 0 then
        renderDrawTexture(player, getX(x), getY(y), iconsize, iconsize, -getCharHeading(playerPed), -1)
      end
      if target["x"] ~= 0 and target["time"] + 50 > os.clock() then
        if getQ(target["x"], target["y"], mapmode) or mapmode == 0 then
          renderDrawTexture(matavoz, getX(target["x"]) - 10, getY(target["y"]) - 10, iconsize * 2, iconsize * 2, 0, -1)
        end
      end
      for k, v in pairs(data) do
        if k == "nicks" and not settings.map.hide then
          for z, v1 in pairs(v) do
            if getQ(v1["x"], v1["y"], mapmode) or mapmode == 0 then
              if z ~= licensenick then
                --убрать
                if data["timestamp"] - v1["timestamp"] < 60 then
                  if mapmode == 0 then
                    renderFontDrawText(font, v1["health"], getX(v1["x"]) + xmod + 10, getY(v1["y"]) + 2, 0xFF00FF00)
                  else
                    renderFontDrawText(font12, v1["health"], getX(v1["x"]) + 28, getY(v1["y"]) + 4, 0xFF00FF00)
                  end
                  n1, n2 = string.match(z, "(.).+_(.).+")
                  if n1 and n2 then
                    if mapmode == 0 then
                      renderFontDrawText(font, n1 .. n2, getX(v1["x"]) - xmod, getY(v1["y"]) + 2, 0xFF00FF00)
                    else
                      renderFontDrawText(font12, z, getX(v1["x"]) - string.len(z) * 8.3, getY(v1["y"]) + 4, 0xFF00FF00)
                    end
                  end
                  renderDrawTexture(player, getX(v1["x"]), getY(v1["y"]), iconsize, iconsize, -v1["heading"], -1)
                end
              end
            end
          end
        end
        if settings.marker and settings.marker.enable and k == "marker" and v.data then
          renderDrawTexture(marker, getX(v.data.x), getY(v.data.y), iconsize * 2, iconsize * 2, 0, -1)
        end
      end
    end
  end

  local renderpos = function()
    if settings.map.toggle_render and wasKeyPressed(settings.map.render_key) and not sampIsChatInputActive() and not isSampfuncsConsoleActive() and not sampIsDialogActive() then
      active_render = not active_render
    end

    if (isKeyDown(settings.map.render_key) and not sampIsChatInputActive() and not isSampfuncsConsoleActive() and not sampIsDialogActive()) or (active_render and settings.map.toggle_render) then
      local xC, yC, zC = getCharCoordinates(playerPed)
      for k, v in pairs(data) do
        if k == "nicks" and not settings.map.hide then
          for z, v1 in pairs(v) do
            if true and z ~= licensenick then
              local result, wposX, wposY, wposZ = convert3DCoordsToScreenEx(v1["x"], v1["y"], v1["z"])
              if wposZ > 0 then
                local id = sampGetPlayerIdByNickname(z)
                local text = table.concat({
                  table.concat({ z, "[" .. tostring(id) .. "]" }, " "),
                  table.concat({ "Health: ", v1["health"], "hp" }, " "),
                  table.concat({ "Distance: ", math.floor(getDistanceBetweenCoords3d(v1["x"], v1["y"], v1["z"], xC, yC, yZ)), "м" }, " "),
                }, "\n")
                if data["timestamp"] - v1["timestamp"] > 20 then
                  text = text .. "\nLast info: " .. math.floor(data["timestamp"] - v1["timestamp"]) .. "с"
                end
                if id then
                  renderFontDrawText(font, text, wposX, wposY, 0xFF00FF00)
                else
                  renderFontDrawText(font, text, wposX, wposY, 0xFFFF0000)
                end
              end
            end
          end
        end
      end
    end
  end

  local changemaphotkey = function(mode)
    local modes = {
      [1] = " для большой карты",
      [2] = " для 1/4 карты",
      [3] = " для смены режима 1/4 карты",
      [4] = " для рендера ников"
    }

    mode = tonumber(mode)
    sampShowDialog(
            989,
            "Изменение горячей клавиши" .. modes[mode],
            'Нажмите "Окей", после чего нажмите нужную клавишу.\nНастройки будут изменены.',
            "Окей",
            "Закрыть"
    )
    while sampIsDialogActive(989) do
      wait(100)
    end
    local resultMain, buttonMain, typ = sampHasDialogRespond(988)
    if buttonMain == 1 then
      while ke1y == nil do
        wait(0)
        for i = 1, 200 do
          if isKeyDown(i) then
            if mode == 1 then
              settings.map.key1 = i
            end
            if mode == 2 then
              settings.map.key2 = i
            end
            if mode == 3 then
              settings.map.key3 = i
            end
            if mode == 4 then
              settings.map.render_key = i
            end
            sampAddChatMessage("Установлена новая горячая клавиша - " .. key.id_to_name(i), -1)
            addOneOffSound(0.0, 0.0, 0.0, 1052)
            inicfg.save(settings, "edith")
            ke1y = 1
            break
          end
        end
      end
    end
    ke1y = nil

  end

  local dn = function(nam)
    local file = getGameDirectory() .. "\\moonloader\\resource\\edith\\" .. nam
    if not doesFileExist(file) then
      downloadUrlToFile(remoteResourceURL .. nam, file)
      print(remoteResourceURL .. nam)
    end
  end

  local init = function()
    if not doesDirectoryExist(getGameDirectory() .. "\\moonloader\\resource") then
      createDirectory(getGameDirectory() .. "\\moonloader\\resource")
    end
    if not doesDirectoryExist(getGameDirectory() .. "\\moonloader\\resource\\edith") then
      createDirectory(getGameDirectory() .. "\\moonloader\\resource\\edith")
    end

    dn("pla.png")
    dn("matavoz.png")
    dn("marker.png")

    for i = 1, 16 do
      dn(i .. ".png")
      dn(i .. "k.png")
    end

    matavoz = renderLoadTextureFromFile(getGameDirectory() .. "/moonloader/resource/edith/matavoz.png")
    player = renderLoadTextureFromFile(getGameDirectory() .. "/moonloader/resource/edith/pla.png")
    marker = renderLoadTextureFromFile(getGameDirectory() .. "/moonloader/resource/edith/marker.png")

    font = renderCreateFont("Impact", 8, 4)
    font4 = renderCreateFont("Impact", 4, 4)
    font10 = renderCreateFont("Impact", 10, 4)
    font12 = renderCreateFont("Impact", 12, 4)
    font14 = renderCreateFont("Impact", 14, 4)
    font16 = renderCreateFont("Impact", 16, 4)
    font20 = renderCreateFont("Impact", 20, 4)
    font24 = renderCreateFont("Impact", 24, 4)

    resX, resY = getScreenResolution()
    m1 = renderLoadTextureFromFile(getGameDirectory() .. "/moonloader/resource/edith/1.png")
    m2 = renderLoadTextureFromFile(getGameDirectory() .. "/moonloader/resource/edith/2.png")
    m3 = renderLoadTextureFromFile(getGameDirectory() .. "/moonloader/resource/edith/3.png")
    m4 = renderLoadTextureFromFile(getGameDirectory() .. "/moonloader/resource/edith/4.png")
    m5 = renderLoadTextureFromFile(getGameDirectory() .. "/moonloader/resource/edith/5.png")
    m6 = renderLoadTextureFromFile(getGameDirectory() .. "/moonloader/resource/edith/6.png")
    m7 = renderLoadTextureFromFile(getGameDirectory() .. "/moonloader/resource/edith/7.png")
    m8 = renderLoadTextureFromFile(getGameDirectory() .. "/moonloader/resource/edith/8.png")
    m9 = renderLoadTextureFromFile(getGameDirectory() .. "/moonloader/resource/edith/9.png")
    m10 = renderLoadTextureFromFile(getGameDirectory() .. "/moonloader/resource/edith/10.png")
    m11 = renderLoadTextureFromFile(getGameDirectory() .. "/moonloader/resource/edith/11.png")
    m12 = renderLoadTextureFromFile(getGameDirectory() .. "/moonloader/resource/edith/12.png")
    m13 = renderLoadTextureFromFile(getGameDirectory() .. "/moonloader/resource/edith/13.png")
    m14 = renderLoadTextureFromFile(getGameDirectory() .. "/moonloader/resource/edith/14.png")
    m15 = renderLoadTextureFromFile(getGameDirectory() .. "/moonloader/resource/edith/15.png")
    m16 = renderLoadTextureFromFile(getGameDirectory() .. "/moonloader/resource/edith/16.png")
    m1k = renderLoadTextureFromFile(getGameDirectory() .. "/moonloader/resource/edith/1k.png")
    m2k = renderLoadTextureFromFile(getGameDirectory() .. "/moonloader/resource/edith/2k.png")
    m3k = renderLoadTextureFromFile(getGameDirectory() .. "/moonloader/resource/edith/3k.png")
    m4k = renderLoadTextureFromFile(getGameDirectory() .. "/moonloader/resource/edith/4k.png")
    m5k = renderLoadTextureFromFile(getGameDirectory() .. "/moonloader/resource/edith/5k.png")
    m6k = renderLoadTextureFromFile(getGameDirectory() .. "/moonloader/resource/edith/6k.png")
    m7k = renderLoadTextureFromFile(getGameDirectory() .. "/moonloader/resource/edith/7k.png")
    m8k = renderLoadTextureFromFile(getGameDirectory() .. "/moonloader/resource/edith/8k.png")
    m9k = renderLoadTextureFromFile(getGameDirectory() .. "/moonloader/resource/edith/9k.png")
    m10k = renderLoadTextureFromFile(getGameDirectory() .. "/moonloader/resource/edith/10k.png")
    m11k = renderLoadTextureFromFile(getGameDirectory() .. "/moonloader/resource/edith/11k.png")
    m12k = renderLoadTextureFromFile(getGameDirectory() .. "/moonloader/resource/edith/12k.png")
    m13k = renderLoadTextureFromFile(getGameDirectory() .. "/moonloader/resource/edith/13k.png")
    m14k = renderLoadTextureFromFile(getGameDirectory() .. "/moonloader/resource/edith/14k.png")
    m15k = renderLoadTextureFromFile(getGameDirectory() .. "/moonloader/resource/edith/15k.png")
    m16k = renderLoadTextureFromFile(getGameDirectory() .. "/moonloader/resource/edith/16k.png")
    xmod = 15
    if resX >= 1300 and resY >= 1300 then
      bX = (resX - 1300) / 2
      bY = (resY - 1300) / 2
      size = 1300
      xmod = 24
      font = renderCreateFont("Impact", 14, 4)
    elseif resX > 1024 and resY >= 1024 then
      bX = (resX - 1024) / 2
      bY = (resY - 1024) / 2
      size = 1024
      xmod = 20
      font = renderCreateFont("Impact", 12, 4)
    elseif resX > 720 and resY >= 720 then
      bX = (resX - 720) / 2
      bY = (resY - 720) / 2
      size = 720
    else
      bX = (resX - 512) / 2
      bY = (resY - 512) / 2
      size = 512
    end
  end

  local mainThread = function()
    init()
    while true do
      wait(0)
      x, y = getCharCoordinates(playerPed)
      if settings.map.show then
        fastmap()
      end
      if settings.map.render_pos then
        renderpos()
      end
    end
  end

  local getMenu = function()
    return {
      title = "{7ef3fa}* " .. ((settings.map.show or not settings.map.hide) and "{00ff66}" or "{ff0000}") .. "GLONASS",
      submenu = {
        {
          title = "Информация о модуле",
          onclick = function()
            sampShowDialog(
                    0,
                    "{7ef3fa}/edith v." .. thisScript().version .. ' - информация о модуле {00ff66}"GLONASS"',
                    "{00ff66}GLONASS\n{ffffff}Модуль предназначен для быстрого обмена координатами.\nКоординаты передаются через сервер между всеми юзерами.\n\n{7ef3fa}" .. tostring(key.id_to_name(settings.map.key1)) .. "{ffffff} - открыть всю карту со всеми доступными данными.\n{7ef3fa}" .. tostring(key.id_to_name(settings.map.key2)) .. "{ffffff} - открыть 1/4 карты. Стрелками можно перемещаться по ней.\n{7ef3fa}" .. tostring(key.id_to_name(settings.map.key3)) .. "{ffffff} - сменить режим 1/4 карты: карта с квадратами или обычная.\n\nНа карте отмечаются:\n\n{7ef3fa}1. Ваши координаты и направление.\n{7ef3fa}2. Координаты других юзеров.{ffffff}\n   *Слева от метки 2 буквы - инициалы.\n   *Справа от метки - HP.\n{ffffff}При перехвате вражеского перегона маркер трака дублируется на карте.\nДобавлен рендер игроков на {7ef3fa}" .. tostring(key.id_to_name(settings.map.render_key)) .. "{ffffff}, можно отключить.",
                    "Окей"
            )
          end
        },
        {
          title = "Вкл/выкл модуля: " .. tostring((settings.map.show or not settings.map.hide)),
          onclick = function()
            if (settings.map.show or not settings.map.hide) then
              settings.map.show = false
              settings.map.hide = true
            else
              settings.map.show = true
              settings.map.hide = false
            end
            inicfg.save(settings, "edith")
          end
        },
        {
          title = " "
        },
        {
          title = "Изменить клавиши активации",
          submenu = {
            {
              title = "Открыть большую карту - {7ef3fa}" .. key.id_to_name(settings.map.key1),
              onclick = function()
                table.insert(tempThreads, lua_thread.create(changemaphotkey, 1))
              end
            },
            {
              title = "Открыть 1/4 карты - {7ef3fa}" .. key.id_to_name(settings.map.key2),
              onclick = function()
                table.insert(tempThreads, lua_thread.create(changemaphotkey, 2))
              end
            },
            {
              title = "Сменить режим 1/4 карты- {7ef3fa}" .. key.id_to_name(settings.map.key3),
              onclick = function()
                table.insert(tempThreads, lua_thread.create(changemaphotkey, 3))
              end
            }
          }
        },
        {
          title = " "
        },
        {
          title = "Прозрачность: " .. tostring(settings.map.alphastring),
          submenu = {
            {
              title = "100%",
              onclick = function()
                settings.map.alpha = 0xFFFFFFFF
                settings.map.alphastring = "100%"
                inicfg.save(settings, "edith")
              end
            },
            {
              title = "95%",
              onclick = function()
                settings.map.alpha = 0xF2FFFFFF
                settings.map.alphastring = "95%"
                inicfg.save(settings, "edith")
              end
            },
            {
              title = "90%",
              onclick = function()
                settings.map.alpha = 0xE6FFFFFF
                settings.map.alphastring = "90%"
                inicfg.save(settings, "edith")
              end
            },
            {
              title = "85%",
              onclick = function()
                settings.map.alpha = 0xD9FFFFFF
                settings.map.alphastring = "85%"
                inicfg.save(settings, "edith")
              end
            },
            {
              title = "80%",
              onclick = function()
                settings.map.alpha = 0xCCFFFFFF
                settings.map.alphastring = "80%"
                inicfg.save(settings, "edith")
              end
            },
            {
              title = "75%",
              onclick = function()
                settings.map.alpha = 0xBFFFFFFF
                settings.map.alphastring = "75%"
                inicfg.save(settings, "edith")
              end
            },
            {
              title = "70%",
              onclick = function()
                settings.map.alpha = 0xB3FFFFFF
                settings.map.alphastring = "70%"
                inicfg.save(settings, "edith")
              end
            },
            {
              title = "65%",
              onclick = function()
                settings.map.alpha = 0xA6FFFFFF
                settings.map.alphastring = "65%"
                inicfg.save(settings, "edith")
              end
            },
            {
              title = "60%",
              onclick = function()
                settings.map.alpha = 0x99FFFFFF
                settings.map.alphastring = "60%"
                inicfg.save(settings, "edith")
              end
            },
            {
              title = "55%",
              onclick = function()
                settings.map.alpha = 0x8CFFFFFF
                settings.map.alphastring = "55%"
                inicfg.save(settings, "edith")
              end
            },
            {
              title = "50%",
              onclick = function()
                settings.map.alpha = 0x80FFFFFF
                settings.map.alphastring = "50%"
                inicfg.save(settings, "edith")
              end
            },
            {
              title = "45%",
              onclick = function()
                settings.map.alpha = 0x73FFFFFF
                settings.map.alphastring = "45%"
                inicfg.save(settings, "edith")
              end
            },
            {
              title = "40%",
              onclick = function()
                settings.map.alpha = 0x66FFFFFF
                settings.map.alphastring = "40%"
                inicfg.save(settings, "edith")
              end
            },
            {
              title = "35%",
              onclick = function()
                settings.map.alpha = 0x59FFFFFF
                settings.map.alphastring = "35%"
                inicfg.save(settings, "edith")
              end
            },
            {
              title = "30%",
              onclick = function()
                settings.map.alpha = 0x4DFFFFFF
                settings.map.alphastring = "30%"
                inicfg.save(settings, "edith")
              end
            },
            {
              title = "25%",
              onclick = function()
                settings.map.alpha = 0x40FFFFFF
                settings.map.alphastring = "25%"
                inicfg.save(settings, "edith")
              end
            },
            {
              title = "20%",
              onclick = function()
                settings.map.alpha = 0x33FFFFFF
                settings.map.alphastring = "20%"
                inicfg.save(settings, "edith")
              end
            },
            {
              title = "15%",
              onclick = function()
                settings.map.alpha = 0x26FFFFFF
                settings.map.alphastring = "15%"
                inicfg.save(settings, "edith")
              end
            },
            {
              title = "10%",
              onclick = function()
                settings.map.alpha = 0x1AFFFFFF
                settings.map.alphastring = "10%"
                inicfg.save(settings, "edith")
              end
            },
            {
              title = "5%",
              onclick = function()
                settings.map.alpha = 0x0DFFFFFF
                settings.map.alphastring = "5%"
                inicfg.save(settings, "edith")
              end
            },
            {
              title = "0%",
              onclick = function()
                settings.map.alpha = 0x00FFFFFF
                settings.map.alphastring = "0%"
                inicfg.save(settings, "edith")
              end
            }
          }
        },
        {
          title = "Показывать карту на {7ef3fa}" .. key.id_to_name(settings.map.key1) .. "{ffffff} и {7ef3fa}" .. key.id_to_name(settings.map.key2) .. "{ffffff}: " .. tostring(settings.map.show),
          onclick = function()
            settings.map.show = not settings.map.show
            inicfg.save(settings, "edith")
          end
        },
        {
          title = "Скрывать мои координаты: " .. tostring(settings.map.hide),
          onclick = function()
            settings.map.hide = not settings.map.hide
            inicfg.save(settings, "edith")
          end
        },
        {
          title = "Скрывать транспорт от сервера: " .. tostring(settings.map.hide_v),
          onclick = function()
            settings.map.hide_v = not settings.map.hide_v
            inicfg.save(settings, "edith")
          end
        },
        {
          title = "Переключать вместо удержания: " .. tostring(settings.map.toggle),
          onclick = function()
            settings.map.toggle = not settings.map.toggle
            inicfg.save(settings, "edith")
          end
        },
        {
          title = " "
        },
        {
          title = "Отмечать на карте грузовик при перехвате перегона: " .. tostring(settings.map.truck),
          onclick = function()
            settings.map.truck = not settings.map.truck
            inicfg.save(settings, "edith")
          end
        },
        {
          title = "Отмечать звуком изменение координат грузовика: " .. tostring(settings.map.truck_sound),
          onclick = function()
            settings.map.truck_sound = not settings.map.truck_sound
            inicfg.save(settings, "edith")
          end
        },
        {
          title = " "
        },
        {
          title = "Включить рендер: " .. tostring(settings.map.render_pos),
          onclick = function()
            settings.map.render_pos = not settings.map.render_pos
            inicfg.save(settings, "edith")
          end
        },
        {
          title = "Клавиша рендера - {7ef3fa}" .. key.id_to_name(settings.map.render_key),
          onclick = function()
            table.insert(tempThreads, lua_thread.create(changemaphotkey, 4))
          end
        },
        {
          title = "Тогл вместо удержания: " .. tostring(settings.map.toggle_render),
          onclick = function()
            settings.map.toggle_render = not settings.map.toggle_render
            active_render = false
            inicfg.save(settings, "edith")
          end
        },
        {
          title = " "
        },
        {
          title = "Debug информация: " .. tostring(settings.map.debug),
          onclick = function()
            settings.map.debug = not settings.map.debug
            inicfg.save(settings, "edith")
          end
        }
      }
    }
  end

  local description = function()
    return "{7ef3fa}* " .. ((settings.map.show or not settings.map.hide) and "{00ff66}" or "{ff0000}") .. "GLONASS - {ffffff}Глобальная карта пользователей на {00ccff}" .. tostring(key.id_to_name(settings.map.key1)) .. "{ffffff}, 1/4 - {00ccff}" .. tostring(key.id_to_name(settings.map.key2)) .. "{ffffff}, режим 1/4 - {00ccff}" .. tostring(key.id_to_name(settings.map.key3)) .. "{ffffff}, рендер - {00ccff}" .. tostring(key.id_to_name(settings.map.render_key)) .. "{ffffff}."
  end

  local enableAll = function()
    settings.map.show = true
    settings.map.hide = false
    settings.map.render_pos = true
  end

  local disableAll = function()
    settings.map.show = false
    settings.map.hide = true
    settings.map.render_pos = false
  end

  local defaults = {
    toggle = false,
    idfura = 506 + 42,
    sqr = false,
    hide = false,
    hide_v = false,
    show = true,
    alpha = 0xFFFFFFFF,
    alphastring = "100%",
    debug = false,
    key1 = 77,
    key2 = 188,
    key3 = 0x4B,
    truck = true,
    truck_sound = true,
    render_pos = true,
    render_key = 0x5A,
    toggle_render = false
  }

  local prepare = function(request_table)
    request_table["request"] = 0

    local _, myid = sampGetPlayerIdByCharHandle(playerPed)
    if not _ then
      return
    end
    if getActiveInterior() == 0 and sampGetPlayerScore(myid) >= 1 and not settings.map.hide then
      local x, y, z = getCharCoordinates(playerPed)
      request_table["sender"] = {
        sender = licensenick,
        pos = { x = math.floor(x), y = math.floor(y), z = math.floor(z) },
        heading = math.floor(getCharHeading(playerPed)),
        health = getCharHealth(playerPed)
      }
    end

    if isKeyDown(settings.map.key1) or isKeyDown(settings.map.key2) or active then
      request_table["request"] = 1
    end
    if settings.map.render_pos and (isKeyDown(settings.map.render_key) or active_render) then
      request_table["request"] = 1
    end
    if active_all and (isKeyDown(settings.map.key1) or isKeyDown(settings.map.key2)) then
      request_table["request"] = 2
    end
  end

  local process = function(response)
    data['nicks'] = response['nicks']
    data['timestamp'] = response['timestamp']
    if settings.marker and settings.marker.enable then
      data["marker"] = response["marker"]
    end
  end

  local onSetMapIcon = function(iconId, position, type, color, style)
    if settings.map.truck then
      if type == 51 then
        target = { x = position.x, y = position.y, z = position.z, time = os.clock() }
        if settings.map.truck_sound then
          addOneOffSound(0.0, 0.0, 0.0, 1052)
        end
      end
    end
  end

  return {
    main = mainThread,
    getMenu = getMenu,
    desc = description,
    enable = enableAll,
    disable = disableAll,
    defaults = defaults,
    prepare = prepare,
    process = process,
    onSetMapIcon = onSetMapIcon
  }
end
--------------------------------------------------------------------------------
-------------------------------------TWEAKS-------------------------------------
--------------------------------------------------------------------------------
function tweaksModule()
  ffi.cdef [[
    typedef unsigned long HANDLE;
    typedef HANDLE HWND;
    typedef const char *LPCTSTR;

    HWND GetActiveWindow(void);

    bool SetWindowTextA(HWND hWnd, LPCTSTR lpString);
]]

  local getMenu = function()
    return {
      title = "Мелкие твики",
      submenu = {
        {
          title = "Скрывать /gov: " .. tostring(settings.tweaks.hidegov),
          onclick = function()
            settings.tweaks.hidegov = not settings.tweaks.hidegov
            inicfg.save(settings, "edith")
          end
        },
        {
          title = "Скрывать ~~~~~ и рекламу /ask и music и сайта: " .. tostring(settings.tweaks.hideshit),
          onclick = function()
            settings.tweaks.hideshit = not settings.tweaks.hideshit
            inicfg.save(settings, "edith")
          end
        },
        {
          title = "Скрывать объявления в чате (адблок): " .. tostring(settings.tweaks.adblock),
          onclick = function()
            settings.tweaks.adblock = not settings.tweaks.adblock
            inicfg.save(settings, "edith")
          end
        },

        {
          title = " ",
        },
        {
          title = "Игнорировать shift в оконном режиме при потере фокуса (антипауза): " .. tostring(settings.tweaks.shift),
          onclick = function()
            settings.tweaks.shift = not settings.tweaks.shift
            inicfg.save(settings, "edith")
            thisScript():reload()
          end
        },
        {
          title = "Заменить имя окна на ник персонажа. Конфликтует с QuickBinder!: " .. tostring(settings.tweaks.windowtext),
          onclick = function()
            settings.tweaks.windowtext = not settings.tweaks.windowtext
            inicfg.save(settings, "edith")
            thisScript():reload()
          end
        },
        {
          title = "Заблокировать выбор радио в машине: " .. tostring(settings.tweaks.radio),
          onclick = function()
            settings.tweaks.radio = not settings.tweaks.radio
            inicfg.save(settings, "edith")
            thisScript():reload()
          end
        },
      }
    }
  end

  local description = function()
    return "{ffffff}Вы можете включить несколько полезных твиков в разделе 'Мелкие твики'\nНапример: заблокировать радио в игре, скрыть объявления (/ad), /gov и так далее..."
  end

  local enableAll = function()
    settings.tweaks.hidegov = true
    settings.tweaks.hideshit = true
    settings.tweaks.adblock = true
    settings.tweaks.shift = true
    settings.tweaks.radio = true
  end

  local disableAll = function()
    settings.tweaks.hidegov = false
    settings.tweaks.hideshit = false
    settings.tweaks.adblock = false
    settings.tweaks.shift = false
    settings.tweaks.radio = false
  end

  local defaults = {
    hidegov = false,
    adblock = false,
    hideshit = false,
    radio = false,
    shift = false,
    windowtext = false
  }

  local shift = function()
    memory.fill(0x00531155, 0x90, 5, true)
  end

  local radio = function()
    memory.copy(0x4EB9A0, memory.strptr('\xC2\x04\x00'), 3, true)
  end

  local windowtext = function()
    ffi.C.SetWindowTextA(ffi.C.GetActiveWindow(), "SA:MP - " .. sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))) .. ' (' .. sampGetPlayerScore(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))) .. ')')
  end

  local onServerMessageAdBlock = function(color, text)
    if settings.tweaks.adblock then
      if color == 14221567 and string.find(text, "Объявление:") then
        return false
      end
      if color == 14221567 and string.find(text, "сотрудник") then
        return false
      end
    end
  end

  local onServerMessageHideShit = function(color, text)
    if settings.tweaks.hideshit then
      if color == -1950935126 and text:find("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~") then
        return false
      end
      if color == 751250602 and text:find("ваш вопрос в поддержку сервера") then
        return false
      end
      if color == 751250602 and text:find("вместе с музыкой от официального") then
        return false
      end
      if color == 751250602 and text:find("интересующую вас информацию вы можете") then
        return false
      end
    end
  end

  local onServerMessageHideGov = function(color, text)
    if settings.tweaks.hidegov then
      if color == -1 and text:find("Государственные Новости") then
        return false
      end
      if color == 641859327 and text:find("Новости:") then
        return false
      end
    end
  end

  return {
    main = mainThread,
    getMenu = getMenu,
    desc = description,
    enable = enableAll,
    disable = disableAll,
    defaults = defaults,
    shift = shift,
    radio = radio,
    windowtext = windowtext,
    onServerMessageAdBlock = onServerMessageAdBlock,
    onServerMessageHideShit = onServerMessageHideShit,
    onServerMessageHideGov = onServerMessageHideGov
  }
end
--------------------------------------------------------------------------------
----------------------------------CAPTURETIMER----------------------------------
--------------------------------------------------------------------------------
function capturetimerModule()
  local waitforcapture = false
  local waitfordraw = false
  local checkafk = os.time()
  local sendtype = 0
  local senddraw = {}
  local timeleft_type = 0
  local timeleft_base
  local timeleft
  local timeleft_minute
  local timeleft_seconds
  local sleep = 0

  local antiFlood = function()
    repeat
      wait(100)
      local res, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
      local ms = math.ceil(os.clock() * 1000 - sleep)
    until ms > 1200 and sampGetPlayerScore(id) >= 1 and not sampIsDialogActive() and not sampIsChatInputActive()
  end

  local mainThread = function()
    while true do
      wait(1000)
      if settings.capturetimer.enable then
        checkafk = os.time()
        if timeleft_type ~= 0 then
          if timeleft_type == 25 then
            timeleft = timeleft_base + 1500 - os.time()
          elseif timeleft_type == 10 then
            timeleft = timeleft_base + 600 - os.time()
          elseif timeleft_type == 2 then
            timeleft = timeleft_base + 120 - os.time()
          end
          timeleft = timeleft + 5 -- фикс +5 секунд
          if timeleft > -60 then
            if timeleft < 600 then
              timeleft_minute = math.floor(timeleft / 60)
              timeleft_seconds = timeleft % 60
              if timeleft_minute < 10 then
                timeleft_minute = "0" .. timeleft_minute
              end
              if timeleft_seconds < 10 then
                timeleft_seconds = "0" .. timeleft_seconds
              end
              sampTextdrawCreate(471, timeleft_minute .. ":" .. timeleft_seconds, settings.capturetimer.posX, settings.capturetimer.posY)
              sampTextdrawSetStyle(471, 3)
              sampTextdrawSetLetterSizeAndColor(471, settings.capturetimer.size1, settings.capturetimer.size2, -65536)
              sampTextdrawSetOutlineColor(471, 1, -16777216)
            else
              timeleft_minute = math.floor(timeleft / 60)
              timeleft_seconds = timeleft % 60
              if timeleft_minute < 10 then
                timeleft_minute = "0" .. timeleft_minute
              end
              if timeleft_seconds < 10 then
                timeleft_seconds = "0" .. timeleft_seconds
              end
              sampTextdrawCreate(471, timeleft_minute .. ":" .. timeleft_seconds, settings.capturetimer.posX, settings.capturetimer.posY)
              sampTextdrawSetStyle(471, 3)
              sampTextdrawSetLetterSizeAndColor(471, settings.capturetimer.size1, settings.capturetimer.size2, -13447886)
              sampTextdrawSetOutlineColor(471, 1, -16777216)
            end
          else
            if sampTextdrawIsExists(471) then
              sampTextdrawDelete(471)
            end
          end
        else
          if sampTextdrawIsExists(471) then
            sampTextdrawDelete(471)
          end
        end
      end
    end
  end

  local changepos = function()
    local bckpX1 = settings.capturetimer.posX
    local bckpY1 = settings.capturetimer.posY
    local bckpS1 = settings.capturetimer.size1
    local bckpS2 = settings.capturetimer.size2
    sampShowDialog(
            3838,
            "Изменение положения и размера.",
            '{ffcc00}Изменение положения textdraw.\n{ffffff}Изменить положение можно с помощью стрелок клавы.\n\n{ffcc00}Изменение размера textdraw.\n{ffffff}Изменить размер ПРОПОРЦИОНАЛЬНО можно с помощью {00ccff}\' - \'{ffffff} и {00ccff}\' + \'{ffffff}.\n{ffffff}Изменить размер по горизонтали можно с помощью {00ccff}\'9\'{ffffff} и {00ccff}\'0\'{ffffff}.\n{ffffff}Изменить размер по вертикали можно с помощью {00ccff}\'7\'{ffffff} и {00ccff}\'8\'{ffffff}.\n\n{ffcc00}Как принять изменения?\n{ffffff}Нажмите "Enter", чтобы принять изменения.\nНажмите пробел, чтобы отменить изменения.\nВ меню можно восстановить дефолт.',
            "Я понял"
    )
    while sampIsDialogActive(3838) == true do
      wait(100)
    end
    while true do
      wait(0)
      print(1)
      if bckpY1 > 0 and bckpY1 < 480 and bckpX1 > 0 and bckpX1 < 640 then
        wait(0)
        if isKeyDown(40) and bckpY1 + 1 < 480 then
          bckpY1 = bckpY1 + 1
        end
        if isKeyDown(38) and bckpY1 - 1 > 0 then
          bckpY1 = bckpY1 - 1
        end
        if isKeyDown(37) and bckpX1 - 1 > 0 then
          bckpX1 = bckpX1 - 1
        end
        if isKeyDown(39) and bckpX1 + 1 < 640 then
          bckpX1 = bckpX1 + 1
        end
        if isKeyJustPressed(57) then
          if bckpS1 - 0.1 > 0 then
            bckpS1 = bckpS1 - 0.1
          end
        end
        if isKeyJustPressed(48) then
          if bckpS1 + 0.1 > 0 then
            bckpS1 = bckpS1 + 0.1
          end
        end
        if isKeyJustPressed(55) then
          if bckpS2 - 0.1 > 0 then
            bckpS2 = bckpS2 - 0.1
          end
        end
        if isKeyJustPressed(56) then
          if bckpS2 + 0.1 > 0 then
            bckpS2 = bckpS2 + 0.1
          end
        end
        if isKeyJustPressed(57) then
          if bckpS1 - 0.1 > 0 then
            bckpS1 = bckpS1 - 0.1
          end
        end
        if isKeyJustPressed(48) then
          if bckpS1 + 0.1 > 0 then
            bckpS1 = bckpS1 + 0.1
          end
        end
        if isKeyJustPressed(55) then
          if bckpS2 - 0.1 > 0 then
            bckpS2 = bckpS2 - 0.1
          end
        end
        if isKeyJustPressed(56) then
          if bckpS2 + 0.1 > 0 then
            bckpS2 = bckpS2 + 0.1
          end
        end
        if isKeyJustPressed(189) then
          if bckpS1 - 0.1 > 0 then
            bckpS1 = bckpS1 - 0.1
            bckpS2 = bckpS1 * 5
          end
        end
        if isKeyJustPressed(187) then
          if bckpS1 + 0.1 > 0 then
            bckpS1 = bckpS1 + 0.1
            bckpS2 = bckpS1 * 5
          end
        end
        sampTextdrawCreate(423, "10" .. ":" .. "00", bckpX1, bckpY1)
        sampTextdrawSetStyle(423, 3)
        sampTextdrawSetLetterSizeAndColor(423, bckpS1, bckpS2, -13447886)
        sampTextdrawSetOutlineColor(423, 1, -16777216)
        if isKeyJustPressed(13) then
          sampTextdrawDelete(423)
          settings.capturetimer.posX = bckpX1
          settings.capturetimer.posY = bckpY1
          settings.capturetimer.size1 = bckpS1
          settings.capturetimer.size2 = bckpS2
          addOneOffSound(0.0, 0.0, 0.0, 1052)
          inicfg.save(settings, "edith")
          break
        end
        if isKeyJustPressed(32) then
          sampTextdrawDelete(423)
          addOneOffSound(0.0, 0.0, 0.0, 1053)
          break
        end
      end
    end
  end

  local getMenu = function()
    return {
      title = "{7ef3fa}* " .. (settings.capturetimer.enable and "{00ff66}" or "{ff0000}") .. "CAPTURETIMER",
      submenu = {
        {
          title = "Информация о модуле",
          onclick = function()
            sampShowDialog(
                    0,
                    "{7ef3fa}/edith v." .. thisScript().version .. ' - информация о модуле {00ff66}"CAPTURETIMER"',
                    "{00ff66}CAPTURETIMER{ffffff}\nСкрипт отображает таймер до конца стрелы в правом нижнем углу.\nРаботает как через сервер, так и если он лежит.\n\nПримечания:\n* Есть функция авто /clist 0 после конца капта.",
                    "Окей"
            )
          end
        },
        {
          title = "Вкл/выкл модуля: " .. tostring(settings.capturetimer.enable),
          onclick = function()
            settings.capturetimer.enable = not settings.capturetimer.enable
            inicfg.save(settings, "edith")
          end
        },
        {
          title = " "
        },
        {
          title = "Авто '/clist 0' после конца капта: " .. tostring(settings.capturetimer.clistoff),
          onclick = function()
            settings.capturetimer.clistoff = not settings.capturetimer.clistoff
            inicfg.save(settings, "edith")
          end
        },
        {
          title = "Изменить позицию и размер",
          onclick = function()
            table.insert(tempThreads, lua_thread.create(changepos))
          end
        },
      }
    }
  end

  local description = function()
    return "{7ef3fa}* " .. (settings.capturetimer.enable and "{00ff66}" or "{ff0000}") .. "CAPTURETIMER - {ffffff}Таймер стрел с синхронизацией между юзерами."
  end

  local enableAll = function()
    settings.capturetimer.enable = true
  end

  local disableAll = function()
    settings.capturetimer.enable = false
  end

  --' Вам объявили войну Sons of Silence MC! Начало через 15 минут. Ваша задача удержать зону, отмеченную на карте'
  --' Nick_Name объявил войну Vagos MC! Начало через 15 минут. Ваша задача удержать зону, отмеченную на карте'
  --' Вам объявили войну Hell’s Angels MC! Начало через 15 минут. Ваша задача удержать зону, отмеченную н'
  local onServerMessage = function(color, text)
    if string.find(text, "ачало через 15 минут") and string.find(text, "войн") then
      if not (os.time() - checkafk > 5) then
        waitforcapture = true
        sendtype = 25
      end
    end

    if text == " Война началась! Победит тот, кто прогонит врага из зоны, или убьет больше человек" then
      if not (os.time() - checkafk > 5) then
        waitforcapture = true
        sendtype = 10
      end
    end

    if text == " Победитель не определен! Война продлена на 2 минуты" then
      if not (os.time() - checkafk > 5) then
        waitforcapture = true
        sendtype = 2
      end
    end

    if text == " Ваш клуб выиграл!" then
      table.insert(tempThreads, lua_thread.create(
              function()
                if settings.capturetimer.enable and settings.capturetimer.clistoff then
                  antiFlood()
                  sampSendChat("/clist 0")
                end
              end
      ))
      if not (os.time() - checkafk > 5) then
        waitforcapture = true
        sendtype = -1
      end
    end

    if text == " Ваш клуб проиграл!" then
      table.insert(tempThreads, lua_thread.create(
              function()
                if settings.capturetimer.enable and settings.capturetimer.clistoff then
                  antiFlood()
                  sampSendChat("/clist 0")
                end
              end
      ))
      if not (os.time() - checkafk > 5) then
        waitforcapture = true
        sendtype = -2
      end
    end
  end

  local onSendChat = function(message)
    sleep = os.clock() * 1000
  end

  local onSendCommand = function(cmd)
    sleep = os.clock() * 1000
  end

  local prepare = function(request_table)
    if waitforcapture then
      request_table["timeleft_type"] = sendtype
      waitforcapture = false
    end
    if waitfordraw then
      request_table["textdraw"] = senddraw
      waitfordraw = false
    end
  end

  local process = function(ad)
    if ad["capture"]["time"] ~= nil then
      if timeleft_type ~= ad["capture"]["type"] or ad["capture"]["type"] == 2 then
        timeleft_type = ad["capture"]["type"]
        timeleft_base = math.floor(ad["capture"]["time"] + math.floor(os.time() - ad["timestamp"]))
      end
    end
  end

  local defaults = {
    enable = true,
    clistoff = true,
    posX = 588,
    posY = 428,
    size1 = 0.5,
    size2 = 2
  }

  local onShowTextDraw = function(id, tab)
    if id and tab then
      if not (os.time() - checkafk > 5) then
        if tab.text:find("~y~KILLS~n~") then
          senddraw = {}
          senddraw.type = "new"
          senddraw.text = tab.text:gsub("’", "")
          waitfordraw = true
          --print(tab.text)
          --~n~~g~Rifa: ~w~0~n~~r~Aztec: ~w~1
          --task send to server to initiate capture w/o timing
        end
      end
    end
  end

  local onTextDrawSetString = function(id, str)
    if not (os.time() - checkafk > 5) then
      if str:find("~y~KILLS~n~") then
        senddraw = {}
        senddraw.type = "upd"
        senddraw.text = str:gsub("’", "")
        waitfordraw = true
        --print(str)
        --~n~~g~Rifa: ~w~0~n~~r~Aztec: ~w~1
        --task send to server
      end
    end
  end

  return {
    main = mainThread,
    getMenu = getMenu,
    desc = description,
    enable = enableAll,
    disable = disableAll,
    defaults = defaults,
    onServerMessage = onServerMessage,
    onSendChat = onSendChat,
    onSendCommand = onSendCommand,

    onShowTextDraw = onShowTextDraw,
    onTextDrawSetString = onTextDrawSetString,

    prepare = prepare,
    process = process
  }
end
--------------------------------------------------------------------------------
-------------------------------------SCORE--------------------------------------
--------------------------------------------------------------------------------
function scoreModule()
  local given = 0
  local k_given = 0
  local kills = 0
  local k_kills = 0
  local deaths = 0
  local mode = false

  local last_in = os.time()

  local getending = function(count)
    count = count % 10
    if count == 0 then
      return "убийств"
    elseif count == 1 then
      return "убийство"
    elseif count == 2 or count == 3 or count == 4 then
      return "убийства"
    elseif count >= 5 then
      return "убийств"
    end
  end

  local resetscore = function()
    settings.stats.dmg = 0
    settings.stats.kills = 0
    settings.stats.deaths = 0
    k_given = 0
    given = 0
    kills = 0
    k_kills = 0
    deaths = 0
    addOneOffSound(0.0, 0.0, 0.0, 1052)
    inicfg.save(settings, "edith")
  end

  local changepos = function()
    local bckpX1 = settings.score.posX
    local bckpY1 = settings.score.posY
    local bckpS1 = settings.score.size1
    local bckpS2 = settings.score.size2
    sampShowDialog(
            3838,
            "Изменение положения и размера.",
            '{ffcc00}Изменение положения textdraw.\n{ffffff}Изменить положение можно с помощью стрелок клавы.\n\n{ffcc00}Изменение размера textdraw.\n{ffffff}Изменить размер ПРОПОРЦИОНАЛЬНО можно с помощью {00ccff}\' - \'{ffffff} и {00ccff}\' + \'{ffffff}.\n{ffffff}Изменить размер по горизонтали можно с помощью {00ccff}\'9\'{ffffff} и {00ccff}\'0\'{ffffff}.\n{ffffff}Изменить размер по вертикали можно с помощью {00ccff}\'7\'{ffffff} и {00ccff}\'8\'{ffffff}.\n\n{ffcc00}Как принять изменения?\n{ffffff}Нажмите "Enter", чтобы принять изменения.\nНажмите пробел, чтобы отменить изменения.\nВ меню можно восстановить дефолт.',
            "Я понял"
    )
    while sampIsDialogActive(3838) == true do
      wait(100)
    end
    while true do
      wait(0)
      if bckpY1 > 0 and bckpY1 < 480 and bckpX1 > 0 and bckpX1 < 640 then
        wait(0)
        if isKeyDown(40) and bckpY1 + 1 < 480 then
          bckpY1 = bckpY1 + 1
        end
        if isKeyDown(38) and bckpY1 - 1 > 0 then
          bckpY1 = bckpY1 - 1
        end
        if isKeyDown(37) and bckpX1 - 1 > 0 then
          bckpX1 = bckpX1 - 1
        end
        if isKeyDown(39) and bckpX1 + 1 < 640 then
          bckpX1 = bckpX1 + 1
        end
        if isKeyJustPressed(57) then
          if bckpS1 - 0.1 > 0 then
            bckpS1 = bckpS1 - 0.1
          end
        end
        if isKeyJustPressed(48) then
          if bckpS1 + 0.1 > 0 then
            bckpS1 = bckpS1 + 0.1
          end
        end
        if isKeyJustPressed(55) then
          if bckpS2 - 0.1 > 0 then
            bckpS2 = bckpS2 - 0.1
          end
        end
        if isKeyJustPressed(56) then
          if bckpS2 + 0.1 > 0 then
            bckpS2 = bckpS2 + 0.1
          end
        end
        if isKeyJustPressed(57) then
          if bckpS1 - 0.1 > 0 then
            bckpS1 = bckpS1 - 0.1
          end
        end
        if isKeyJustPressed(48) then
          if bckpS1 + 0.1 > 0 then
            bckpS1 = bckpS1 + 0.1
          end
        end
        if isKeyJustPressed(55) then
          if bckpS2 - 0.1 > 0 then
            bckpS2 = bckpS2 - 0.1
          end
        end
        if isKeyJustPressed(56) then
          if bckpS2 + 0.1 > 0 then
            bckpS2 = bckpS2 + 0.1
          end
        end
        if isKeyJustPressed(189) then
          if bckpS1 - 0.1 > 0 then
            bckpS1 = bckpS1 - 0.1
            bckpS2 = bckpS1 * 5
          end
        end
        if isKeyJustPressed(187) then
          if bckpS1 + 0.1 > 0 then
            bckpS1 = bckpS1 + 0.1
            bckpS2 = bckpS1 * 5
          end
        end
        sampTextdrawCreate(422, "999", bckpX1, bckpY1)
        sampTextdrawSetStyle(422, 3)
        sampTextdrawSetLetterSizeAndColor(422, bckpS1, bckpS2, -1)
        sampTextdrawSetOutlineColor(422, 1, -16777216)
        if isKeyJustPressed(13) then
          sampTextdrawDelete(422)
          settings.score.posX = bckpX1
          settings.score.posY = bckpY1
          settings.score.size1 = bckpS1
          settings.score.size2 = bckpS2
          addOneOffSound(0.0, 0.0, 0.0, 1052)
          inicfg.save(settings, "edith")
          sampTextdrawSetPos(440, settings.score.posX, settings.score.posY)
          sampTextdrawSetLetterSizeAndColor(440, settings.score.size1, settings.score.size2, -1)
          break
        end
        if isKeyJustPressed(32) then
          sampTextdrawDelete(422)
          addOneOffSound(0.0, 0.0, 0.0, 1053)
          break
        end
      end
    end
  end

  local changehotkey = function(mode)
    local modes = {
      [1] = " для дамага за всё время",
      [2] = " для убийств",
      [3] = " для смертей",
      [4] = " для k/d",
      [5] = " для смены режима сеанс/всё время"
    }
    if tonumber(mode) == nil or tonumber(mode) < 1 or tonumber(mode) > 5 then
      sampAddChatMessage(
              "1) Посмотреть дамаг за сеанс: " ..
                      key.id_to_name(settings.score.key1) ..
                      ". 2) Посмотреть убийства: " ..
                      key.id_to_name(settings.score.key2) ..
                      ". 3) Посмотреть смерти: " ..
                      key.id_to_name(settings.score.key3) ..
                      ". 4) k/d: " ..
                      key.id_to_name(settings.score.key4) ..
                      ". 5) Сеанс/всё время: " .. key.id_to_name(settings.score.key5) .. ".",
              -1
      )
      sampAddChatMessage("Изменить: /ediscorekey [1|2|3|4|5]", -1)
    else
      mode = tonumber(mode)
      sampShowDialog(
              989,
              "Изменение горячей клавиши" .. modes[mode],
              'Нажмите "Окей", после чего нажмите нужную клавишу.\nНастройки будут изменены.',
              "Окей",
              "Закрыть"
      )
      while sampIsDialogActive(989) do
        wait(100)
      end
      local resultMain, buttonMain, typ = sampHasDialogRespond(988)
      if buttonMain == 1 then
        while ke1y == nil do
          wait(0)
          for i = 1, 200 do
            if isKeyDown(i) then
              if mode == 1 then
                settings.score.key1 = i
              end
              if mode == 2 then
                settings.score.key2 = i
              end
              if mode == 3 then
                settings.score.key3 = i
              end
              if mode == 4 then
                settings.score.key4 = i
              end
              if mode == 5 then
                settings.score.key5 = i
              end
              sampAddChatMessage("Установлена новая горячая клавиша - " .. key.id_to_name(i), -1)
              addOneOffSound(0.0, 0.0, 0.0, 1052)
              inicfg.save(settings, "edith")
              ke1y = 1
              break
            end
          end
        end
      end
      ke1y = nil
    end
  end

  local getbodypart = function(part)
    if part == nil then
      return "?"
    end
    local names = {
      [3] = "Торс",
      [4] = "Писю",
      [5] = "Левую руку",
      [6] = "Правую руку",
      [7] = "Левую ногу",
      [8] = "Правую ногу",
      [9] = "Голову"
    }
    return names[part]
  end

  local getweaponname = function(weapon)
    -- getweaponname by FYP
    if weapon == nil then
      return "?"
    end
    local names = {
      [0] = "Кулака",
      [1] = "Кастета",
      [2] = "Клюшки для гольфа",
      [3] = "Полицейской дубинки",
      [4] = "Ножа",
      [5] = "Биты",
      [6] = "Лопаты",
      [7] = "Кия",
      [8] = "Катаны",
      [9] = "Бензопилы",
      [10] = "Розового дилдо",
      [11] = "Дилдо",
      [12] = "Вибратора",
      [13] = "Серебрянного вибратора",
      [14] = "Цветов",
      [15] = "Трости",
      [16] = "Гранаты",
      [17] = "Слезоточивого газа",
      [18] = "Коктейля молотова",
      [22] = "Пистолета",
      [23] = "Пистолета с глушителем",
      [24] = "Deagle",
      [25] = "Shotgun",
      [26] = "Обреза",
      [27] = "Боевого дробовика",
      [28] = "Micro SMG/Uzi",
      [29] = "MP5",
      [30] = "AK-47",
      [31] = "M4",
      [32] = "Tec-9",
      [33] = "Винтовки",
      [34] = "Снайперской винтовки",
      [35] = "РПГ",
      [36] = "HS Rocket",
      [37] = "Огнемёта",
      [38] = "Минигана",
      [39] = "Satchel Charge",
      [40] = "Detonator",
      [41] = "Газового балончика",
      [42] = "Огнетушителя",
      [43] = "Camera",
      [44] = "Night Vis Goggles",
      [45] = "Thermal Goggles",
      [46] = "Parachute"
    }
    return names[weapon]
  end

  local monitor = function()
    while true do
      wait(200)
      if settings.score.enable and isCharDead(PLAYER_PED) then
        if killer ~= nil and killer_id ~= nil and killer_w ~= nil and killer_b ~= nil and getweaponname(killer_w) ~= nil and getbodypart(killer_b) ~= nil then
          if os.time() - last_in < 2 then
            sampAddChatMessage(
                    "{7ef3fa}[EDITH]:{ef3226} " ..
                            killer ..
                            "{808080}[" ..
                            killer_id ..
                            "]{ffffff} убил вас из {ef3226}" ..
                            getweaponname(killer_w) .. "{ffffff} прямо в {ef3226}" .. getbodypart(killer_b) .. ".",
                    -1
            )
          end
        end
        if k_given ~= nil and k_kills ~= nil then
          sampAddChatMessage(
                  "{7ef3fa}[EDITH]: {ffffff}За жизнь вы нанесли {ef3226}" ..
                          math.floor(k_given) ..
                          "{ffffff} урона, у вас {ef3226}" .. k_kills .. "{ffffff} " .. getending(k_kills) .. ".",
                  -1
          )
        end
        k_given = 0
        k_kills = 0
        deaths = deaths + 1
        settings.stats.deaths = settings.stats.deaths + 1
        inicfg.save(settings, "edith")
        while isCharDead(PLAYER_PED) ~= false do
          wait(200)
        end
      end
    end
  end

  local mainThread = function()
    if settings.score.enable then
      sampTextdrawCreate(440, "0", settings.score.posX, settings.score.posY)
      sampTextdrawSetStyle(440, 3)
      sampTextdrawSetLetterSizeAndColor(440, settings.score.size1, settings.score.size2, -1)
      sampTextdrawSetOutlineColor(440, 1, -16777216)

      table.insert(tempThreads, lua_thread.create(monitor))

      while true do
        wait(700)
        if isKeyDown(settings.score.key1) and sampIsDialogActive() == false and sampIsChatInputActive() == false and isPauseMenuActive() == false then
          if mode then
            sampTextdrawSetString(440, string.format("%2.1f", settings.stats.dmg))
          else
            sampTextdrawSetString(440, string.format("%2.1f", given))
          end
        elseif isKeyDown(settings.score.key2) and sampIsDialogActive() == false and sampIsChatInputActive() == false and isPauseMenuActive() == false then
          if mode then
            sampTextdrawSetString(440, string.format("K:%d", settings.stats.kills))
          else
            sampTextdrawSetString(440, string.format("K:%d", kills))
          end
        elseif isKeyDown(settings.score.key3) and sampIsDialogActive() == false and sampIsChatInputActive() == false and isPauseMenuActive() == false then
          if mode then
            sampTextdrawSetString(440, string.format("D:%d", settings.stats.deaths))
          else
            sampTextdrawSetString(440, string.format("D:%d", deaths))
          end
        elseif isKeyDown(settings.score.key4) and sampIsDialogActive() == false and sampIsChatInputActive() == false and isPauseMenuActive() == false then
          if mode then
            sampTextdrawSetString(440, string.format("K/D:%2.1f", settings.stats.kills / settings.stats.deaths))
          else
            sampTextdrawSetString(440, string.format("K/D:%2.1f", kills / deaths))
          end
        elseif wasKeyPressed(settings.score.key5) and sampIsDialogActive() == false and sampIsChatInputActive() == false and isPauseMenuActive() == false then
          mode = not mode
          addOneOffSound(0.0, 0.0, 0.0, 1052)
          if mode then
            sampTextdrawSetLetterSizeAndColor(440, settings.score.size1, settings.score.size2, -65536)
          else
            sampTextdrawSetLetterSizeAndColor(440, settings.score.size1, settings.score.size2, -1)
          end
        else
          if mode then
            sampTextdrawSetString(440, string.format("%2.1f", k_given))
          else
            sampTextdrawSetString(440, string.format("%2.1f", k_given))
          end
        end
      end
    end
  end

  local getMenu = function()
    return {
      title = "{7ef3fa}* " .. (settings.score.enable and "{00ff66}" or "{ff0000}") .. "EDISCORE",
      submenu = {
        {
          title = "Информация о модуле",
          onclick = function()
            sampShowDialog(
                    0,
                    "{7ef3fa}/edith v." .. thisScript().version .. ' - информация о модуле {00ff66}"EDISCORE"',
                    "{00ff66}EDISCORE{ffffff}\nФункция считает дамаг, смерти и килы, сообщает о результативности после смерти.\nОна рисует текстдрав, на котором по умолчанию нанесенный вами урон за жизнь.\n\nНажмите {7ef3fa}" ..
                            key.id_to_name(settings.score.key1) ..
                            "{ffffff}, чтобы показать весь урон.\nНажмите {7ef3fa}" ..
                            key.id_to_name(settings.score.key2) ..
                            "{ffffff}, чтобы показать убийства.\nНажмите {7ef3fa}" ..
                            key.id_to_name(settings.score.key3) ..
                            "{ffffff}, чтобы показать смерти.\nНажмите {7ef3fa}" ..
                            key.id_to_name(settings.score.key4) ..
                            "{ffffff}, чтобы показать соотношение убийств к смертям.\nНажмите {7ef3fa}" ..
                            key.id_to_name(settings.score.key5) ..
                            "{ffffff}, чтобы сменить режим: за сеанс (белый) или за всё время (красный).",
                    "Окей"
            )
          end
        },
        {
          title = "Посмотреть статистику",
          onclick = function()
            sampShowDialog(
                    0,
                    "{7ef3fa}Ваша статистика",
                    "{00ff66}За жизнь:{ffffff}\nУрон: " ..
                            tostring(k_given) ..
                            "\nУбийств: " ..
                            tostring(k_kills) ..
                            "\n{00ff66}За сеанс:{ffffff}\nУрон: " ..
                            tostring(given) ..
                            "\nУбийств: " ..
                            tostring(kills) ..
                            "\nСмертей: " ..
                            tostring(deaths) ..
                            "\n" ..
                            string.format("K/D: %2.1f", kills / deaths) ..
                            "\n{00ff66}За всё время:{ffffff}\nУрон: " ..
                            string.format("%2.1f", settings.stats.dmg) ..
                            "\nУбийств: " ..
                            tostring(settings.stats.kills) ..
                            "\nСмертей: " ..
                            tostring(settings.stats.deaths) ..
                            "\n" ..
                            string.format(
                                    "K/D: %2.1f",
                                    settings.stats.kills / settings.stats.deaths
                            ),
                    "Окей"
            )
          end
        },
        {
          title = " "
        },
        {
          title = "Вкл/выкл модуля: " .. tostring(settings.score.enable),
          onclick = function()
            settings.score.enable = not settings.score.enable
            if not settings.score.enable then
              sampTextdrawDelete(440)
            end
            inicfg.save(settings, "edith")
          end
        },
        {
          title = " "
        },
        {
          title = "Сбросить счётчик",
          onclick = function()
            table.insert(tempThreads, lua_thread.create(resetscore))
          end
        },
        {
          title = " "
        },
        {
          title = "Изменить позицию и размер",
          onclick = function()
            table.insert(tempThreads, lua_thread.create(changepos))
          end
        },
        {
          title = "Изменить клавишу активации",
          submenu = {
            {
              title = "Показать весь урон - {7ef3fa}" .. key.id_to_name(settings.score.key1),
              onclick = function()
                table.insert(tempThreads, lua_thread.create(changehotkey, 1))
              end
            },
            {
              title = "Показать убийства - {7ef3fa}" .. key.id_to_name(settings.score.key2),
              onclick = function()
                table.insert(tempThreads, lua_thread.create(changehotkey, 2))
              end
            },
            {
              title = "Показать смерти - {7ef3fa}" .. key.id_to_name(settings.score.key3),
              onclick = function()
                table.insert(tempThreads, lua_thread.create(changehotkey, 3))
              end
            },
            {
              title = "Показать K/D - {7ef3fa}" .. key.id_to_name(settings.score.key4),
              onclick = function()
                table.insert(tempThreads, lua_thread.create(changehotkey, 4))
              end
            },
            {
              title = "Смена режима (белый - сеанс, красный - всё время) - {7ef3fa}" ..
                      key.id_to_name(settings.score.key5),
              onclick = function()
                table.insert(tempThreads, lua_thread.create(changehotkey, 5))
              end
            }
          },
          {
            title = "[4] Восстановить дефолтные настройки",
            onclick = function()
              cmdDrugsTxdDefault()
            end
          }
        }
      }
    }
  end

  local description = function()
    return "{7ef3fa}* " .. (settings.score.enable and "{00ff66}" or "{ff0000}") .. "EDISCORE - {ffffff}Считает дамаг, смерти и килы. Отчет в чат после смерти."
  end

  local enableAll = function()
    settings.score.enable = true
  end

  local disableAll = function()
    settings.score.enable = false
  end

  local defaults = {
    posX = 23,
    posY = 426,
    size1 = 0.4,
    size2 = 2,
    key1 = 49,
    key2 = 50,
    enable = true,
    key3 = 51,
    key4 = 52,
    key5 = 53
  }

  local stats = {
    dmg = 0,
    kills = 0,
    deaths = 0
  }

  local onSendGiveDamage = function(playerID, damage, weaponID, bodypart)
    if sampIsPlayerConnected(playerID) then
      result, handle2 = sampGetCharHandleBySampPlayerId(playerID)
      if result then
        health = sampGetPlayerHealth(playerID)
        if health < damage or health == 0 then
          kills = kills + 1
          k_kills = k_kills + 1
          settings.stats.kills = settings.stats.kills + 1
          inicfg.save(settings, "edith")
        end
      end
      k_given = k_given + damage
      given = given + damage
      settings.stats.dmg = settings.stats.dmg + damage
      inicfg.save(settings, "edith")
    end
  end

  local onSendTakeDamage = function(playerID, damage, weaponID, bodypart)
    if sampIsPlayerConnected(playerID) then
      killer = sampGetPlayerNickname(playerID)
      killer_id = playerID
      killer_w = weaponID
      killer_b = bodypart
      last_in = os.time()
    end
  end

  return {
    main = mainThread,
    getMenu = getMenu,
    desc = description,
    enable = enableAll,
    disable = disableAll,
    defaults = defaults,
    stats = stats,
    onSendGiveDamage = onSendGiveDamage,
    onSendTakeDamage = onSendTakeDamage
  }
end
--------------------------------------------------------------------------------
-------------------------------------BLIST--------------------------------------
--------------------------------------------------------------------------------
function bikerlistModule()
  local attackers = {}
  local defenders = {}
  local ATTACK_COLOR = 2865496064
  local DEFEN_COLOR = 2855877036

  local current_nick = ""

  local afk = {}
  local status0 = " "
  local status1 = " "
  local status2 = " "

  local check = false
  local lasttime = 0
  local count = 0

  local isStream = function(searchid)
    for k, PED in pairs(getAllChars()) do
      local res, id = sampGetPlayerIdByCharHandle(PED)
      if res then
        if sampIsPlayerConnected(id) and sampGetPlayerNickname(id) == sampGetPlayerNickname(searchid) then
          return "{00FFFF}Да"
        end
      end
    end
    return "{808080}Нет"
  end

  local getAfk = function(id)
    _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
    if myid == id then
      return "N/A"
    elseif sampIsPlayerConnected(id) then
      if afk[sampGetPlayerNickname(id)] == nil then
        return "-"
      else
        return afk[sampGetPlayerNickname(id)]
      end
    end
  end

  local bl_update = function()
    attackers = {}
    defenders = {}
    _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
    for i = 0, sampGetMaxPlayerId(false) do
      if sampIsPlayerConnected(i) or (_ and myid == i) then
        if sampGetPlayerColor(i) == ATTACK_COLOR then
          table.insert(attackers, i)
        elseif sampGetPlayerColor(i) == DEFEN_COLOR then
          table.insert(defenders, i)
        end
      end
    end
    text = ""
    text = text .. "№\tВ прорисовке\tНик\tAFK\n"
    text = text .. " \tОбновить\n" .. status0 .. "\t" .. status1 .. "\t" .. status2 .. "\tcheck\n \t{DC143C}Атака:\n"
    kolvo_a = 0
    for k, v in pairs(attackers) do
      text = text ..
              string.format(
                      "{DC143C}%s\t%s\t{DC143C}%s\t{DC143C}%s\n",
                      k,
                      isStream(v),
                      string.format("%s{808080}[%s]", sampGetPlayerNickname(v), v),
                      getAfk(v)
              )
      if isStream(v) == "{00FFFF}Да" then
        kolvo_a = kolvo_a + 1
      end
    end
    text = text .. " \t{1E90FF}Защита:\n"
    kolvo_d = 0
    for k, v in pairs(defenders) do
      text = text ..
              string.format(
                      "{1E90FF}%s\t%s\t{1E90FF}%s\t{1E90FF}%s\n",
                      k,
                      isStream(v),
                      string.format("%s{808080}[%s]", sampGetPlayerNickname(v), v),
                      getAfk(v)
              )
      if isStream(v) == "{00FFFF}Да" then
        kolvo_d = kolvo_d + 1
      end
    end
    if lasttime == 0 then
      caption = "Проверок не было."
    else
      caption = string.format("Была %u с. назад", os.time() - lasttime)
    end
    sampShowDialog(
            4172,
            string.format(
                    "{808080}[/bikerlist] {DC143C}Атака: %u/%u. {1E90FF}Защита: %u/%u. %s",
                    kolvo_a,
                    #attackers,
                    kolvo_d,
                    #defenders,
                    caption
            ),
            text,
            string.format("{DC143C}%u.%u", kolvo_a, #attackers),
            string.format("{1E90FF}%u.%u", kolvo_d, #defenders),
            5
    )
  end

  local checkAfk = function()
    afk = {}
    check = true
    count = 0
    for k, v in pairs(attackers) do
      if sampIsPlayerConnected(v) then
        current_nick = sampGetPlayerNickname(v)
        status0 = tostring(count) .. "/" .. tostring(#attackers + #defenders)
        status1 = "Проверяю "
        status2 = current_nick
        sampSendChat("/id " .. v)
        bl_update()
        wait(1000)
      end
    end
    for k, v in pairs(defenders) do
      if sampIsPlayerConnected(v) then
        current_nick = sampGetPlayerNickname(v)
        status0 = tostring(count) .. "/" .. tostring(#attackers + #defenders)
        status1 = "Проверяю "
        status2 = current_nick
        sampSendChat("/id " .. v)
        bl_update()
        wait(1000)
      end
    end
    bl_update()
    check = false
    status0 = " "
    status1 = " "
    status2 = " "
    lasttime = os.time()
  end

  local checkTab = function()
    bl_update()
    while sampIsDialogActive() and sampGetCurrentDialogId() == 4172 do
      wait(20)
      local result, button, list, input = sampHasDialogRespond(4172)
      if result then
        if button == 1 and list == 1 then
          bl_update()
          table.insert(tempThreads, lua_thread.create(checkAfk))
        elseif button == 1 and list == 0 then
          wait(100)
          bl_update()
        end
      end
    end
  end

  local register = function()
    sampRegisterChatCommand(
            "bl",
            function()
              table.insert(tempThreads, lua_thread.create(checkTab))
            end
    )

    sampRegisterChatCommand(
            "bll",
            function()
              table.insert(tempThreads, lua_thread.create(checkTab))
            end
    )
  end

  local getMenu = function()
    return {
      title = "{7ef3fa}* " .. (settings.bikerlist.enable and "{00ff66}" or "{ff0000}") .. "BIKERLIST",
      submenu = {
        {
          title = "Информация о модуле",
          onclick = function()
            sampShowDialog(
                    0,
                    "{7ef3fa}/edith v." .. thisScript().version .. ' - информация о модуле {00ff66}"BIKERLIST"',
                    "{00ff66}BIKERLIST{ffffff}\nВо время стрелы сервер устанавливает байкерам уникальные клисты.\nСкрипт проверяет таб и выводит диалог с полезной информацией.\n\n{7ef3fa}/bl(l){ffffff} - открыть байкерлист.\n\nПримечания:\n* Диалог обновляется когда он открыт.\n* Можно проверить игроков на афк в том же диалоге.\n* Может быть случай, когда игрок с прошлой стрелы не изменил клист.",
                    "Окей"
            )
          end
        },
        {
          title = "Вкл/выкл модуля: " .. tostring(settings.bikerlist.enable),
          onclick = function()
            settings.bikerlist.enable = not settings.bikerlist.enable
            inicfg.save(settings, "edith")
            thisScript():reload()
          end
        },
        {
          title = " "
        },
        {
          title = "Открыть байкерлист",
          onclick = function()
            table.insert(tempThreads, lua_thread.create(checkTab))
          end
        }
      }
    }
  end

  local description = function()
    return "{7ef3fa}* " .. (settings.bikerlist.enable and "{00ff66}" or "{ff0000}") .. "BIKERLIST - {ffffff} Чекер таба на стрелах байкеров, активация - {00ccff}/bl{ffffff}."
  end

  local enableAll = function()
    settings.bikerlist.enable = true
  end

  local disableAll = function()
    settings.bikerlist.enable = false
  end

  local defaults = {
    enable = true
  }

  local onServerMessage = function(color, text)
    if check and color == -1 then
      if string.find(text, current_nick) ~= nil then
        if string.find(text, "AFK") == nil and string.find(text, "SLEEP") == nil then
          afk[current_nick] = "AWAKE"
        else
          afk[current_nick] = string.match(text, current_nick .. " %[%d+%] %[LVL: %d+%] %[(.+)%]")
        end
        count = count + 1
        return false
      end
    end
  end

  return {
    register = register,
    getMenu = getMenu,
    desc = description,
    enable = enableAll,
    disable = disableAll,
    defaults = defaults,
    onServerMessage = onServerMessage
  }
end
--------------------------------------------------------------------------------
-------------------------------------CIPHER-------------------------------------
--------------------------------------------------------------------------------
function cipherModule(key1, key2)
  -- This is your secret 67-bit key (any random bits are OK)
  local Key53 = key1 or 8186454 + 421123564365098
  local Key14 = key2 or 4842

  local inv256

  local sleep = 0

  local antiFlood = function()
    repeat
      wait(100)
      local res, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
      local ms = math.ceil(os.clock() * 1000 - sleep)
    until ms > 1200 and sampGetPlayerScore(id) >= 1 and not sampIsDialogActive() and not sampIsChatInputActive()
  end

  local encode = function(str)
    if not inv256 then
      inv256 = {}
      for M = 0, 127 do
        local inv = -1
        repeat
          inv = inv + 2
        until inv * (2 * M + 1) % 256 == 1
        inv256[M] = inv
      end
    end
    local K, F = Key53, 16384 + Key14
    return (str:gsub(
            ".",
            function(m)
              local L = K % 274877906944 -- 2^38
              local H = (K - L) / 274877906944
              local M = H % 128
              m = m:byte()
              local c = (m * inv256[M] - (H - M) / 128) % 256
              K = L * F + H + c + m
              return ("%02x"):format(c)
            end
    ))
  end

  local decode = function(str)
    local K, F = Key53, 16384 + Key14
    return (str:gsub(
            "%x%x",
            function(c)
              local L = K % 274877906944 -- 2^38
              local H = (K - L) / 274877906944
              local M = H % 128
              c = tonumber(c, 16)
              local m = (c + (H - M) / 128) * (2 * M + 1) % 256
              K = L * F + H + c + m
              return string.char(m)
            end
    ))
  end

  local getMenu = function()
    return {
      title = "{7ef3fa}* " .. (settings.cipher.enable and "{00ff66}" or "{ff0000}") .. "CIPHER",
      submenu = {
        {
          title = "Информация о модуле",
          onclick = function()
            sampShowDialog(
                    0,
                    "{7ef3fa}/edith v." .. thisScript().version .. ' - информация о модуле {00ff66}"Cipher"',
                    "{00ff66}CIPHER{ffffff}\n{ffffff}Простой шифр /f, шифрует чат до 35 символов.\n\nИспользование: /fe [text] или /re [text].\nВ настройках можно включить автозамену /r|f на /re|fe, но не рекомендуется.\n\nДля тех, у кого эдит:\n{FFFF00} ENCRYPTED | Prospect  Veasi_Yexela[77]: Это зашифрованная строка\n{ffffff}Для всех будет выглядеть так:\n {01eff1}Prospect  Veasi_Yexela[77]:  ЕNС: 75de96c180c8f0eecd7f551c8ab821334ea19cd3ae8dfee0",
                    "Окей"
            )
          end
        },
        {
          title = "Вкл/выкл модуля: " .. tostring(settings.cipher.enable),
          onclick = function()
            settings.cipher.enable = not settings.cipher.enable
            inicfg.save(settings, "edith")
          end
        },
        {
          title = " "
        },
        {
          title = "Вкл/выкл авто /r -> /re | /f -> /fe: " .. tostring(settings.cipher.auto),
          onclick = function()
            settings.cipher.auto = not settings.cipher.auto
            inicfg.save(settings, "edith")
          end
        }
      }
    }
  end

  local description = function()
    return "{7ef3fa}* " .. (settings.cipher.enable and "{00ff66}" or "{ff0000}") .. "CIPHER - {ffffff}Шифрование в /r или /f чат через {00ccff}/re [текст]{ffffff} или {00ccff}/fe [текст]{ffffff}."
  end

  local enableAll = function()
    settings.cipher.enable = true
  end

  local disableAll = function()
    settings.cipher.enable = false
  end

  local defaults = {
    auto = false,
    enable = true
  }

  local onServerMessage = function(color, text)
    if settings.cipher.enable then
      if color == 33357823 and string.find(text, "ЕNС: ") ~= nil then
        prefix, text = string.match(text, "(.+) ЕNС: (.+)")
        text = decode(text)
        return { 0xFFFF00AA, "ENCRYPTED |" .. prefix .. text }
      end
    end
  end

  local onSendCommand = function(cmd)
    if settings.cipher.enable then
      if settings.cipher.auto and string.find(cmd, "/[r|f] (.+)") and not string.find(cmd, "ЕNС: ") then
        cmd = "/re " .. string.match(cmd, "/[r|f] (.+)")
      end
      if string.find(cmd, "/[f|r]e (.+)") then
        local message = string.match(cmd, "/[f|r]e (.+)")
        if string.len(message) > 35 then
          table.insert(tempThreads, lua_thread.create(
                  function()
                    local ind, max = 1, math.ceil(string.len(message) / 32)
                    for i = 1, max do
                      wait(100)
                      local mes = ((i == 1 and "") or "..") .. string.sub(message, ind, ind + 32) .. ((max == i and "") or "..")
                      if mes ~= "" then
                        antiFlood()
                        sampSendChat(string.format("/f ЕNС: %s", encode(mes)))
                      end
                      ind = ind + 33
                    end
                  end
          ))
          return false
        end
        sampSendChat(string.format("/f ЕNС: %s", encode(message)))
        return false
      else
        sleep = os.clock() * 1000
      end
    end
  end

  return {
    main = mainThread,
    getMenu = getMenu,
    desc = description,
    enable = enableAll,
    disable = disableAll,
    defaults = defaults,
    onServerMessage = onServerMessage,
    onSendCommand = onSendCommand
  }
end
--------------------------------------------------------------------------------
-------------------------------------HEIST--------------------------------------
--------------------------------------------------------------------------------
function heistbeepModule()
  local heist_timestamp = 0
  local hooked_pickup = 0

  local mainThread = function()
    font_beep = renderCreateFont("Impact", 15, 4)
    local resX1, resY1 = getScreenResolution()
    while true do
      wait(0)
      if settings.heist.enable and heist_t == true then
        renderFontDrawText(
                font_beep,
                string.format("Груз: %.3f", (heist_timestamp - os.clock()) * -1),
                resX1 / 2 - 100,
                resY1 / 2,
                0xFF00FF00
        )
        if os.clock() >= heist_timestamp + 5.15 then
          if settings.heist.sound then
            addOneOffSound(0.0, 0.0, 0.0, 1138)
          end
          heist_t = false
        end
      end
    end
  end

  local getMenu = function()
    return {
      title = "{7ef3fa}* " .. (settings.heist.enable and "{00ff66}" or "{ff0000}") .. "HEIST BEEP",
      submenu = {
        {
          title = "Информация о модуле",
          onclick = function()
            sampShowDialog(
                    0,
                    "{7ef3fa}/edith v." .. thisScript().version .. ' - информация о модуле {00ff66}"HEIST BEEP"',
                    "{00ff66}HEIST BEEP{ffffff}\nПосле взятия груза отсчитывает 5.15 секунд для следующего.\nРендерит на экран оставшееся время.\nЗвуковое уведомление настраивается в настройках.\n\nВ настройках можно включить блокировку отправки взятия пикапа, когда время не пришло.",
                    "Окей"
            )
          end
        },
        {
          title = " "
        },
        {
          title = "Вкл/выкл модуля: " .. tostring(settings.heist.enable),
          onclick = function()
            settings.heist.enable = not settings.heist.enable
            inicfg.save(settings, "edith")
          end
        },
        {
          title = "Вкл/выкл звука: " .. tostring(settings.heist.sound),
          onclick = function()
            settings.heist.sound = not settings.heist.sound
            inicfg.save(settings, "edith")
          end
        },
        {
          title = " "
        },
        {
          title = "Стоять на метке и тупа грузить: " .. tostring(settings.heist.smart),
          onclick = function()
            settings.heist.smart = not settings.heist.smart
            inicfg.save(settings, "edith")
          end
        },
      }
    }
  end

  local description = function()
    return "{7ef3fa}* " .. (settings.heist.enable and "{00ff66}" or "{ff0000}") .. "HEIST BEEP - {ffffff}Считает сколько осталось времени для след груза при ограблениях."
  end

  local enableAll = function()
    settings.heist.enable = true
  end

  local disableAll = function()
    settings.heist.enable = false
  end

  local defaults = {
    enable = true,
    sound = true,
    smart = false
  }

  local onCreatePickup = function(id, model, pickuptype, position)
    if model == 2358 or model == 2912 or model == 1650 then
      hooked_pickup = id
    end
  end

  local onSendPickedUpPickup = function(id)
    if settings.heist.enable and hooked_pickup ~= 0 then
      if id == hooked_pickup then
        if os.clock() >= heist_timestamp + 5.8 then
          heist_timestamp = os.clock()
          heist_t = true
        else
          if settings.heist.smart then
            return false
          end
        end
      end
    end
  end

  return {
    main = mainThread,
    getMenu = getMenu,
    desc = description,
    enable = enableAll,
    disable = disableAll,
    defaults = defaults,
    onCreatePickup = onCreatePickup,
    onSendPickedUpPickup = onSendPickedUpPickup
  }
end
--------------------------------------------------------------------------------
--------------------------------------TIER--------------------------------------
--------------------------------------------------------------------------------
function tierModule()
  local mainThread = function()
    while true do
      wait(100)
      if settings.tier.enable and wasKeyPressed(settings.tier.key) and sampIsChatInputActive() == false and
              isSampfuncsConsoleActive() == false and
              sampIsDialogActive() == false
      then
        local car = nil
        local untie = false
        if isKeyDown(VK_LMENU) then
          untie = true
        end
        if isCharInAnyCar(playerPed) then
          car = storeCarCharIsInNoSave(playerPed)
        end
        if car and getDriverOfCar(car) == playerPed then
          for seat = 0, getMaximumNumberOfPassengers(car) - 1 do
            local passenger = nil
            if not isCarPassengerSeatFree(car, seat) then
              passenger = getCharInCarPassengerSeat(car, seat)
            end
            if passenger then
              local r, id = sampGetPlayerIdByCharHandle(passenger)
              if r then
                if untie then
                  sampSendChat(string.format("/untie %d", id))
                else
                  sampSendChat(string.format("/tie %d", id))
                end
                local result1, id1 = sampGetPlayerIdByCharHandle(playerPed)
                if result1 then
                  wait(sampGetPlayerPing(id1) * 15)
                end
              end
            end
          end
        end
      end
    end
  end

  local changetierhotkey = function()
    sampShowDialog(
            989,
            "Изменение горячей клавиши активации tier",
            'Нажмите "Окей", после чего нажмите нужную клавишу.\nНастройки будут изменены.',
            "Окей",
            "Закрыть"
    )
    while sampIsDialogActive(989) do
      wait(100)
    end
    local resultMain, buttonMain, typ = sampHasDialogRespond(989)
    if buttonMain == 1 then
      while ke1y == nil do
        wait(0)
        for i = 1, 200 do
          if isKeyDown(i) then
            settings.tier.key = i
            sampAddChatMessage("Установлена новая горячая клавиша - " .. key.id_to_name(settings.tier.key), -1)
            addOneOffSound(0.0, 0.0, 0.0, 1052)
            inicfg.save(settings, "edith")
            ke1y = 1
            break
          end
        end
      end
      ke1y = nil
    end
  end

  local getMenu = function()
    return {
      title = "{7ef3fa}* " .. (settings.tier.enable and "{00ff66}" or "{ff0000}") .. "TIER",
      submenu = {
        {
          title = "Информация о модуле",
          onclick = function()
            sampShowDialog(
                    0,
                    "{7ef3fa}/edith v." .. thisScript().version .. ' - информация о модуле {00ff66}"TIER"',
                    "{00ff66}TIER{ffffff}\n{ffffff}Тупа связыватель\n\nПо нажатию хоткея {00ccff}" ..
                            tostring(key.id_to_name(settings.tier.key)) ..
                            "{ffffff} связывает всех пассажиров.\nРазвязать: зажать ещё и альт.\nУстраняет турели.",
                    "Окей"
            )
          end
        },
        {
          title = "Вкл/выкл модуля: " .. tostring(settings.tier.enable),
          onclick = function()
            settings.tier.enable = not settings.tier.enable
            inicfg.save(settings, "edith")
          end
        },
        {
          title = " "
        },
        {
          title = "Изменить горячую клавишу",
          onclick = function()
            table.insert(tempThreads, lua_thread.create(changetierhotkey))
          end
        }
      }
    }
  end

  local description = function()
    return "{7ef3fa}* " .. (settings.tier.enable and "{00ff66}" or "{ff0000}") .. "TIER - {ffffff}Связывать всех пассажиров: {00ccff}" ..
            tostring(key.id_to_name(settings.tier.key)) ..
            "{ffffff}, развязать: {00ccff}Alt + " ..
            tostring(key.id_to_name(settings.tier.key)) ..
            "{ffffff}."
  end

  local enableAll = function()
    settings.tier.enable = true
  end

  local disableAll = function()
    settings.tier.enable = false
  end

  local defaults = {
    enable = true,
    key = 85
  }

  return {
    main = mainThread,
    getMenu = getMenu,
    desc = description,
    enable = enableAll,
    disable = disableAll,
    defaults = defaults
  }
end
--------------------------------------------------------------------------------
-------------------------------------STRUCK-------------------------------------
--------------------------------------------------------------------------------
function struckModule()
  local stop_struck = false

  local sleep = 0

  local antiFlood = function()
    repeat
      wait(100)
      local res, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
      local ms = math.ceil(os.clock() * 1000 - sleep)
    until ms > 1200 and sampGetPlayerScore(id) >= 1 and not sampIsDialogActive() and not sampIsChatInputActive()
  end

  local getMenu = function()
    return {
      title = "{7ef3fa}* " .. (settings.struck.enable and "{00ff66}" or "{ff0000}") .. "STRUCK",
      submenu = {
        {
          title = "Информация о модуле",
          onclick = function()
            sampShowDialog(
                    0,
                    "{7ef3fa}/edith v." .. thisScript().version .. ' - информация о модуле {00ff66}"STRUCK"',
                    "{00ff66}STRUCK{ffffff}\nАвтопринятие /struck флудером.",
                    "Окей"
            )
          end
        },
        {
          title = "Включить: " .. tostring(settings.struck.enable),
          onclick = function()
            settings.struck.enable = not settings.struck.enable
            inicfg.save(settings, "edith")
          end
        },
      }
    }
  end

  local description = function()
    return "{7ef3fa}* " .. (settings.struck.enable and "{00ff66}" or "{ff0000}") .. "STRUCK - {ffffff}Автопринятие /struck флудером."
  end

  local enableAll = function()
    settings.struck.enable = true
  end

  local disableAll = function()
    settings.struck.enable = false
  end

  local defaults = {
    enable = false
  }

  local onServerMessage = function(color, text)
    if color == -65281 and text:find("Введите: /struck") then
      if settings.struck.enable then
        stop_struck = true
        table.insert(tempThreads, lua_thread.create(
                function()
                  math.randomseed(os.time() + os.clock())
                  wait(math.random(200, 400))
                  if settings.rcapture.active then
                    wait(200)
                  end
                  while stop_struck do
                    wait(0)
                    antiFlood()
                    sampSendChat("/struck")
                  end
                end
        ))
      end
    end

    if color == 1790050303 and text:find("начал задание по доставке груза") or text == " Задание уже начато" then
      stop_struck = false
    end
  end

  local onSendChat = function(message)
    sleep = os.clock() * 1000
  end

  local onSendCommand = function(cmd)
    sleep = os.clock() * 1000
  end

  return {
    getMenu = getMenu,
    desc = description,
    enable = enableAll,
    disable = disableAll,
    defaults = defaults,
    onServerMessage = onServerMessage,
    onSendChat = onSendChat,
    onSendCommand = onSendCommand
  }
end
--------------------------------------------------------------------------------
------------------------------------CAMHACK-------------------------------------
--------------------------------------------------------------------------------
function camhackModule()
  local flymode = 0
  local speed = 1.0
  local radarHud = 0
  local keyPressed = 0
  local posX, posY, posZ = 0, 0, 0
  local angY, angZ = 0, 0
  local radZ, radY = 0, 0
  local sinZ, cosZ = 0, 0
  local sinY, cosY = 0, 0
  local poiX, poiY, poiZ = 0, 0, 0
  local curZ, curY, angPlZ = 0, 0, 0
  local posPlX, posPlY, posPlZ = 0, 0, 0

  local mainThread = function()
    while true do
      wait(0)
      if settings.camhack.enable then
        if isKeyDown(settings.camhack.key) and isKeyDown(VK_1) then
          if flymode == 0 then
            displayRadar(false)
            displayHud(false)
            posX, posY, posZ = getCharCoordinates(playerPed)
            angZ = getCharHeading(playerPed)
            angZ = angZ * -1.0
            setFixedCameraPosition(posX, posY, posZ, 0.0, 0.0, 0.0)
            angY = 0.0
            lockPlayerControl(true)
            flymode = 1
          end
        end
        if flymode == 1 and not sampIsChatInputActive() and not isSampfuncsConsoleActive() then
          offMouX, offMouY = getPcMouseMovement()

          offMouX = offMouX / 4.0
          offMouY = offMouY / 4.0
          angZ = angZ + offMouX
          angY = angY + offMouY

          if angZ > 360.0 then
            angZ = angZ - 360.0
          end
          if angZ < 0.0 then
            angZ = angZ + 360.0
          end

          if angY > 89.0 then
            angY = 89.0
          end
          if angY < -89.0 then
            angY = -89.0
          end

          radZ = math.rad(angZ)
          radY = math.rad(angY)
          sinZ = math.sin(radZ)
          cosZ = math.cos(radZ)
          sinY = math.sin(radY)
          cosY = math.cos(radY)
          sinZ = sinZ * cosY
          cosZ = cosZ * cosY
          sinZ = sinZ * 1.0
          cosZ = cosZ * 1.0
          sinY = sinY * 1.0
          poiX = posX
          poiY = posY
          poiZ = posZ
          poiX = poiX + sinZ
          poiY = poiY + cosZ
          poiZ = poiZ + sinY
          pointCameraAtPoint(poiX, poiY, poiZ, 2)

          curZ = angZ + 180.0
          curY = angY * -1.0
          radZ = math.rad(curZ)
          radY = math.rad(curY)
          sinZ = math.sin(radZ)
          cosZ = math.cos(radZ)
          sinY = math.sin(radY)
          cosY = math.cos(radY)
          sinZ = sinZ * cosY
          cosZ = cosZ * cosY
          sinZ = sinZ * 10.0
          cosZ = cosZ * 10.0
          sinY = sinY * 10.0
          posPlX = posX + sinZ
          posPlY = posY + cosZ
          posPlZ = posZ + sinY
          angPlZ = angZ * -1.0
          --setCharHeading(playerPed, angPlZ)

          radZ = math.rad(angZ)
          radY = math.rad(angY)
          sinZ = math.sin(radZ)
          cosZ = math.cos(radZ)
          sinY = math.sin(radY)
          cosY = math.cos(radY)
          sinZ = sinZ * cosY
          cosZ = cosZ * cosY
          sinZ = sinZ * 1.0
          cosZ = cosZ * 1.0
          sinY = sinY * 1.0
          poiX = posX
          poiY = posY
          poiZ = posZ
          poiX = poiX + sinZ
          poiY = poiY + cosZ
          poiZ = poiZ + sinY
          pointCameraAtPoint(poiX, poiY, poiZ, 2)

          if isKeyDown(VK_W) then
            radZ = math.rad(angZ)
            radY = math.rad(angY)
            sinZ = math.sin(radZ)
            cosZ = math.cos(radZ)
            sinY = math.sin(radY)
            cosY = math.cos(radY)
            sinZ = sinZ * cosY
            cosZ = cosZ * cosY
            sinZ = sinZ * speed
            cosZ = cosZ * speed
            sinY = sinY * speed
            posX = posX + sinZ
            posY = posY + cosZ
            posZ = posZ + sinY
            setFixedCameraPosition(posX, posY, posZ, 0.0, 0.0, 0.0)
          end

          radZ = math.rad(angZ)
          radY = math.rad(angY)
          sinZ = math.sin(radZ)
          cosZ = math.cos(radZ)
          sinY = math.sin(radY)
          cosY = math.cos(radY)
          sinZ = sinZ * cosY
          cosZ = cosZ * cosY
          sinZ = sinZ * 1.0
          cosZ = cosZ * 1.0
          sinY = sinY * 1.0
          poiX = posX
          poiY = posY
          poiZ = posZ
          poiX = poiX + sinZ
          poiY = poiY + cosZ
          poiZ = poiZ + sinY
          pointCameraAtPoint(poiX, poiY, poiZ, 2)

          if isKeyDown(VK_S) then
            curZ = angZ + 180.0
            curY = angY * -1.0
            radZ = math.rad(curZ)
            radY = math.rad(curY)
            sinZ = math.sin(radZ)
            cosZ = math.cos(radZ)
            sinY = math.sin(radY)
            cosY = math.cos(radY)
            sinZ = sinZ * cosY
            cosZ = cosZ * cosY
            sinZ = sinZ * speed
            cosZ = cosZ * speed
            sinY = sinY * speed
            posX = posX + sinZ
            posY = posY + cosZ
            posZ = posZ + sinY
            setFixedCameraPosition(posX, posY, posZ, 0.0, 0.0, 0.0)
          end

          radZ = math.rad(angZ)
          radY = math.rad(angY)
          sinZ = math.sin(radZ)
          cosZ = math.cos(radZ)
          sinY = math.sin(radY)
          cosY = math.cos(radY)
          sinZ = sinZ * cosY
          cosZ = cosZ * cosY
          sinZ = sinZ * 1.0
          cosZ = cosZ * 1.0
          sinY = sinY * 1.0
          poiX = posX
          poiY = posY
          poiZ = posZ
          poiX = poiX + sinZ
          poiY = poiY + cosZ
          poiZ = poiZ + sinY
          pointCameraAtPoint(poiX, poiY, poiZ, 2)

          if isKeyDown(VK_A) then
            curZ = angZ - 90.0
            radZ = math.rad(curZ)
            radY = math.rad(angY)
            sinZ = math.sin(radZ)
            cosZ = math.cos(radZ)
            sinZ = sinZ * speed
            cosZ = cosZ * speed
            posX = posX + sinZ
            posY = posY + cosZ
            setFixedCameraPosition(posX, posY, posZ, 0.0, 0.0, 0.0)
          end

          radZ = math.rad(angZ)
          radY = math.rad(angY)
          sinZ = math.sin(radZ)
          cosZ = math.cos(radZ)
          sinY = math.sin(radY)
          cosY = math.cos(radY)
          sinZ = sinZ * cosY
          cosZ = cosZ * cosY
          sinZ = sinZ * 1.0
          cosZ = cosZ * 1.0
          sinY = sinY * 1.0
          poiX = posX
          poiY = posY
          poiZ = posZ
          poiX = poiX + sinZ
          poiY = poiY + cosZ
          poiZ = poiZ + sinY
          pointCameraAtPoint(poiX, poiY, poiZ, 2)

          if isKeyDown(VK_D) then
            curZ = angZ + 90.0
            radZ = math.rad(curZ)
            radY = math.rad(angY)
            sinZ = math.sin(radZ)
            cosZ = math.cos(radZ)
            sinZ = sinZ * speed
            cosZ = cosZ * speed
            posX = posX + sinZ
            posY = posY + cosZ
            setFixedCameraPosition(posX, posY, posZ, 0.0, 0.0, 0.0)
          end

          radZ = math.rad(angZ)
          radY = math.rad(angY)
          sinZ = math.sin(radZ)
          cosZ = math.cos(radZ)
          sinY = math.sin(radY)
          cosY = math.cos(radY)
          sinZ = sinZ * cosY
          cosZ = cosZ * cosY
          sinZ = sinZ * 1.0
          cosZ = cosZ * 1.0
          sinY = sinY * 1.0
          poiX = posX
          poiY = posY
          poiZ = posZ
          poiX = poiX + sinZ
          poiY = poiY + cosZ
          poiZ = poiZ + sinY
          pointCameraAtPoint(poiX, poiY, poiZ, 2)

          if isKeyDown(VK_SPACE) then
            posZ = posZ + speed
            setFixedCameraPosition(posX, posY, posZ, 0.0, 0.0, 0.0)
          end

          radZ = math.rad(angZ)
          radY = math.rad(angY)
          sinZ = math.sin(radZ)
          cosZ = math.cos(radZ)
          sinY = math.sin(radY)
          cosY = math.cos(radY)
          sinZ = sinZ * cosY
          cosZ = cosZ * cosY
          sinZ = sinZ * 1.0
          cosZ = cosZ * 1.0
          sinY = sinY * 1.0
          poiX = posX
          poiY = posY
          poiZ = posZ
          poiX = poiX + sinZ
          poiY = poiY + cosZ
          poiZ = poiZ + sinY
          pointCameraAtPoint(poiX, poiY, poiZ, 2)

          if isKeyDown(VK_SHIFT) then
            posZ = posZ - speed
            setFixedCameraPosition(posX, posY, posZ, 0.0, 0.0, 0.0)
          end

          radZ = math.rad(angZ)
          radY = math.rad(angY)
          sinZ = math.sin(radZ)
          cosZ = math.cos(radZ)
          sinY = math.sin(radY)
          cosY = math.cos(radY)
          sinZ = sinZ * cosY
          cosZ = cosZ * cosY
          sinZ = sinZ * 1.0
          cosZ = cosZ * 1.0
          sinY = sinY * 1.0
          poiX = posX
          poiY = posY
          poiZ = posZ
          poiX = poiX + sinZ
          poiY = poiY + cosZ
          poiZ = poiZ + sinY
          pointCameraAtPoint(poiX, poiY, poiZ, 2)

          if keyPressed == 0 and isKeyDown(VK_F10) then
            keyPressed = 1
            if radarHud == 0 then
              displayRadar(true)
              displayHud(true)
              radarHud = 1
            else
              displayRadar(false)
              displayHud(false)
              radarHud = 0
            end
          end

          if wasKeyReleased(VK_F10) and keyPressed == 1 then
            keyPressed = 0
          end

          if isKeyDown(187) then
            speed = speed + 0.01
            printStringNow(speed, 1000)
          end

          if isKeyDown(189) then
            speed = speed - 0.01
            if speed < 0.01 then
              speed = 0.01
            end
            printStringNow(speed, 1000)
          end

          if isKeyDown(settings.camhack.key) and isKeyDown(VK_2) then
            displayRadar(true)
            displayHud(true)
            radarHud = 0
            angPlZ = angZ * -1.0
            lockPlayerControl(false)
            restoreCameraJumpcut()
            setCameraBehindPlayer()
            flymode = 0
          end
        end
      end
    end
  end

  local changecamhackhotkey = function()
    sampShowDialog(
            989,
            "Изменение горячей клавиши активации деактивации камхака",
            'Нажмите "Окей", после чего нажмите нужную клавишу.\nНастройки будут изменены.',
            "Окей",
            "Закрыть"
    )
    while sampIsDialogActive(989) do
      wait(100)
    end
    local resultMain, buttonMain, typ = sampHasDialogRespond(988)
    if buttonMain == 1 then
      while ke1y == nil do
        wait(0)
        for i = 1, 200 do
          if isKeyDown(i) then
            settings.camhack.key = i
            sampAddChatMessage("Установлена новая горячая клавиша - " .. key.id_to_name(i), -1)
            addOneOffSound(0.0, 0.0, 0.0, 1052)
            inicfg.save(settings, "edith")
            ke1y = 1
            break
          end
        end
      end
      ke1y = nil
    end
  end

  local getMenu = function()
    return {
      title = "{7ef3fa}* " .. (settings.camhack.enable and "{00ff66}" or "{ff0000}") .. "CAMHACKWW",
      submenu = {
        {
          title = "Информация о модуле",
          onclick = function()
            sampShowDialog(
                    0,
                    "{7ef3fa}/edith v." .. thisScript().version .. ' - информация о модуле {00ff66}"CAMHACKWW"',
                    "{00ff66}CAMHACKWW{ffffff}\n{ffffff}Представляет собой обыкновенный камхак, но с обходом платных варнингов.\n\nПо нажатию хоткея {00ccff}" ..
                            tostring(key.id_to_name(settings.camhack.key)) ..
                            "{ffffff} + 1 камхак активируется.\nПосле нажатия вы сможете свободно управлять камерой через {00ccff}WASD{ffffff}.\nКамеру можно замедлять на {00ccff}SHIFT{ffffff} и ускорять на {00ccff}SPACE{ffffff}.\n{00ccff}F10{ffffff} включает/выключает худ.\nВыключить: {00ccff}" ..
                            tostring(key.id_to_name(settings.camhack.key)) ..
                            '{ffffff} + 2.\n\nЕсли камера залагает, включите и выключите ещё раз.\nВ настройках можно изменить хоткей и вкл/выкл модуль.\n\nАвторы камхака: "sanek a.k.a Maks_Fender, edited by ANIKI", обход варнингов мой',
                    "Окей"
            )
          end
        },
        {
          title = "Вкл/выкл модуля: " .. tostring(settings.camhack.enable),
          onclick = function()
            settings.camhack.enable = not settings.camhack.enable
            inicfg.save(settings, "edith")
          end
        },
        {
          title = "Показывать текст над башкой на любом расстоянии: " .. tostring(settings.camhack.bubble),
          onclick = function()
            settings.camhack.bubble = not settings.camhack.bubble
            inicfg.save(settings, "edith")
          end
        },
        {
          title = "Обходить варнинги: " .. tostring(settings.camhack.antiwarning),
          onclick = function()
            settings.camhack.antiwarning = not settings.camhack.antiwarning
            inicfg.save(settings, "edith")
          end
        },
        {
          title = " "
        },
        {
          title = "Изменить горячую клавишу",
          onclick = function()
            table.insert(tempThreads, lua_thread.create(changecamhackhotkey))
          end
        }
      }
    }
  end

  local description = function()
    return "{7ef3fa}* " .. (settings.camhack.enable and "{00ff66}" or "{ff0000}") .. "CAMHACKWW - {ffffff}Простой {00ccff}WASD{ffffff} камхак с обходом варнингов. Вкл: {00ccff}" .. tostring(key.id_to_name(settings.camhack.key)) .. " + 1{ffffff}, выкл: {00ccff}" .. tostring(key.id_to_name(settings.camhack.key)) .. " + {00ccff}2{ffffff}."
  end

  local enableAll = function()
    settings.camhack.enable = true
  end

  local disableAll = function()
    settings.camhack.enable = false
  end

  local defaults = {
    enable = true,
    bubble = false,
    antiwarning = true,
    key = 90
  }

  local onPlayerChatBubble = function(id, col, dist, dur, msg)
    if flymode == 1 and settings.camhack.bubble then
      return { id, col, 1488, dur, msg }
    end
  end

  local onSendAimSync = function()
    if flymode == 1 and settings.camhack.antiwarning then
      return false
    end
  end

  return {
    main = mainThread,
    getMenu = getMenu,
    desc = description,
    enable = enableAll,
    disable = disableAll,
    defaults = defaults,
    onPlayerChatBubble = onPlayerChatBubble,
    onSendAimSync = onSendAimSync
  }
end
--------------------------------------------------------------------------------
------------------------------------ACAPTURE------------------------------------
--------------------------------------------------------------------------------
function acaptureModule()
  local acapture_enable = false
  local acapture_disable = false
  local acapture_reg = false

  local asodkas, licenseid = sampGetPlayerIdByCharHandle(PLAYER_PED)
  local licensenick = sampGetPlayerNickname(licenseid)

  local command = function()
    if acapture_enable then
      acapture_enable = false
      acapture_disable = true
    elseif acapture_reg == false then
      sampShowDialog(
              1231241,
              "автокапт с синхронизацией",
              "Привет!\nЯ автокапт.\nЗабиваю стрелки за вас, используя ресурсы каптеров максимально эффективно.\nВ следующем окне выберите бизнес для атаки.",
              "Понял",
              "Отмена!"
      )
      while sampIsDialogActive() do
        wait(100)
      end
      local result, button, list, input = sampHasDialogRespond(9872)
      if button == 0 then
        return
      else
        sampSendChat("/capture")
        a_captureid = -1
        a_sel = true
        while a_captureid == -1 do
          wait(0)
        end
        sampShowDialog(
                9875,
                "Все готово",
                string.format(
                        "Сейчас я свяжусь с E.D.I.T.H. и сообщу о том, что появился каптер.\nE.D.I.T.H. выделит вам секунду и будет каптить за вас.\nВы услышите звуки когда капт происходит.\nОтменить - ввести /acapture еще раз.\n\n\n\nНажмите ENTER, чтобы начать каптить.\nНажмите ESCAPE, чтобы отменить операцию."
                ),
                "ENTER",
                "ESCAPE"
        )
        while sampIsDialogActive() do
          wait(100)
        end
        local result, button, list, input = sampHasDialogRespond(9875)
        if button == 0 then
          a_captureid = -1
          return
        end
        acapture_reg = true
      end
    end
  end

  local register = function()
    sampRegisterChatCommand(
            "acapture",
            function()
              table.insert(tempThreads, lua_thread.create(command))
            end
    )
  end

  local getMenu = function()
    return {
      title = "{7ef3fa}* " .. (settings.acapture.enable and "{00ff66}" or "{ff0000}") .. "ACAPTURE",
      submenu = {
        {
          title = "Информация о модуле",
          onclick = function()
            sampShowDialog(
                    0,
                    "{7ef3fa}/edith v." .. thisScript().version .. ' - информация о модуле {00ff66}"ACAPTURE"',
                    "{00ff66}ACAPTURE{ffffff}\nАвтоматический каптер с распределением секунд между каптерами.\nПодробная информация: {00ccff}/acapture{ffffff}.",
                    "Окей"
            )
          end
        },
        {
          title = "Вкл/выкл модуля: " .. tostring(settings.acapture.enable),
          onclick = function()
            settings.acapture.enable = not settings.acapture.enable
            inicfg.save(settings, "edith")
            if sampIsChatCommandDefined("acapture") then
              sampUnregisterChatCommand("acapture")
            end

            thisScript():reload()
          end
        },
        {
          title = " "
        },
        {
          title = "Активировать: /acapture"
        }
      }
    }
  end

  local description = function()
    return "{7ef3fa}* " .. (settings.acapture.enable and "{00ff66}" or "{ff0000}") .. "ACAPTURE - {ffffff}Флудер /capture, которым управляет сервер, активация - {00ccff}/acapture{ffffff}."
  end

  local enableAll = function()
    settings.acapture.enable = true
  end

  local disableAll = function()
    settings.acapture.enable = false
  end

  local defaults = {
    enable = true
  }

  local onShowDialog = function(dialog, style, title, button1, button2, text)
    if acapture_enable and dialog == 212 then
      sampSendDialogResponse(212, 1, a_captureid, -1)
      addOneOffSound(0.0, 0.0, 0.0, 1052)
      return false
    end
  end

  local onSendDialogResponse = function(dialogId, button, listboxId, input)
    if a_sel and dialogId == 212 and a_captureid == -1 then
      if button == 1 then
        a_captureid = listboxId
        a_sel = false
        return false
      end
    end
  end

  local prepare = function(request_table)
    if acapture_reg then
      request_table["capter"] = licensenick
      request_table["type"] = "register"
    elseif acapture_enable then
      request_table["capter"] = licensenick
      request_table["type"] = "ready"
    elseif acapture_disable then
      request_table["capter"] = licensenick
      request_table["type"] = "unregister"
    end
  end

  local process = function(ad)
    if string.find(ad["capter"], "Go capture!") then
      sampShowDialog(
              12312412,
              "Соединение установлено!",
              string.format("Капт начинается! Всего каптеров: %s", string.match(ad["capter"], "%d+"))
      )
      acapture_reg = false
      acapture_enable = true
    elseif acapture_enable and ad["capter"] == "WAIT" then
      --print("ЖДИ")
    elseif acapture_enable and ad["capter"] == "GO" then
      sampSendChat("/capture")
    elseif ad["capter"] == "END" then
      sampShowDialog(12312412, "acapture", "Капт завершен.")
      acapture_enable = false
      acapture_disable = false
      acapture_reg = false
    end
  end

  return {
    main = mainThread,
    getMenu = getMenu,
    desc = description,
    enable = enableAll,
    disable = disableAll,
    defaults = defaults,
    register = register,
    onShowDialog = onShowDialog,
    onSendDialogResponse = onSendDialogResponse,
    prepare = prepare,
    process = process
  }
end
--------------------------------------------------------------------------------
------------------------------------RCAPTURE------------------------------------
--------------------------------------------------------------------------------
function rcaptureModule()
  local auf_count = 0
  local sleep = 0

  local antiFlood = function()
    repeat
      wait(100)
      local res, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
      local ms = math.ceil(os.clock() * 1000 - sleep)
    until ms > 1200 and sampGetPlayerScore(id) >= 1 and not sampIsDialogActive() and not sampIsChatInputActive()
  end

  local mainThread = function()
    if settings.rcapture.active then
      sampShowDialog(1131231, "автокапт после рестарта", "RCAPTURE был отменен.\nПароль и бизнес стерты.", "Понял")
      settings.rcapture.biz = -1
      settings.rcapture.password = ""
      settings.rcapture.active = false
      inicfg.save(settings, "edith")
    else
      sampShowDialog(
              1231241,
              "автокапт после рестарта",
              "Привет!\nЯ капт после рестарта.\nКогда вы зайдете в следующий раз, я введу пароль и каптану.\nВ следующем окне выберите бизнес для атаки.\nПотом введите пароль и можете релогаться после рестарта.",
              "Понял",
              "Отмена!"
      )
      while sampIsDialogActive() do
        wait(100)
      end
      local result, button, list, input = sampHasDialogRespond(9872)
      if button == 0 then
        return
      else
        antiFlood()
        sampSendChat("/capture")
        r_sel = true
        while r_sel do
          wait(0)
        end
        sampShowDialog(
                9827,
                "RCAPTURE - пароль.",
                string.format("Введите пароль от своего аккаунта, чтобы быстро зайти в игру.\n\nОтправьте пустую строку, если у вас свой автологин."),
                "Выбрать",
                "Отмена",
                1
        )
        while sampIsDialogActive() do
          wait(100)
        end
        local result, button, list, input = sampHasDialogRespond(9827)
        if button == 1 then
          settings.rcapture.password = sampGetCurrentDialogEditboxText(9827)
          settings.rcapture.active = true
          sampShowDialog(1131231, "автокапт после рестарта", string.format("RCAPTURE настроен.\n\nКогда вы в следующий раз зайдете в игру, скрипт введет пароль %s.\nПосле этого он дождется спавна игрока и закаптит бизнес с идом %s.\n\nПосле этого пароль и ид бизнесы будут удалены.\n\nP.S. Если вы ошиблись, напишите /rcapture ещё раз.", settings.rcapture.password, settings.rcapture.biz), "Понял")
          inicfg.save(settings, "edith")
        else
          sampShowDialog(1131231, "автокапт после рестарта", "RCAPTURE был отменен.\nПароль и бизнес стерты.", "Понял")
          settings.rcapture.biz = -1
          settings.rcapture.password = ""
          settings.rcapture.active = false
          inicfg.save(settings, "edith")
        end
      end
    end
  end

  local getMenu = function()
    return {
      title = "{7ef3fa}* " .. (settings.rcapture.enable and "{00ff66}" or "{ff0000}") .. "RCAPTURE {808080}[ALFA]",
      submenu = {
        {
          title = "Информация о модуле",
          onclick = function()
            sampShowDialog(
                    0,
                    "{7ef3fa}/edith v." .. thisScript().version .. ' - информация о модуле {00ff66}"rcapture"',
                    "{00ff66}rcapture{ffffff}\nАвтоматический каптер после рестарта с автологином.\nПодробная информация: {00ccff}/rcapture{ffffff}.",
                    "Окей"
            )
          end
        },
        {
          title = "Вкл/выкл модуля: " .. tostring(settings.rcapture.enable),
          onclick = function()
            settings.rcapture.enable = not settings.rcapture.enable
            inicfg.save(settings, "edith")
            if sampIsChatCommandDefined("rcapture") then
              sampUnregisterChatCommand("rcapture")
            end

            thisScript():reload()
          end
        },
        {
          title = " "
        },
        {
          title = "Активировать: /rcapture"
        }
      }
    }
  end

  local description = function()
    return "{7ef3fa}* " .. (settings.rcapture.enable and "{00ff66}" or "{ff0000}") .. "RCAPTURE - {ffffff}Авто /capture после захода на сервер автологином, активация - {00ccff}/rcapture{ffffff}."
  end

  local enableAll = function()
    settings.acapture.enable = true
  end

  local disableAll = function()
    settings.acapture.enable = false
  end

  local defaults = {
    enable = false,
    active = false,
    biz = -1,
    password = "",
  }

  local register = function()
    sampRegisterChatCommand(
            "rcapture",
            function()
              table.insert(tempThreads, lua_thread.create(rcapture.main))
            end
    )
  end

  local onShowDialog = function(dialog, style, title, button1, button2, text)
    if settings.rcapture.enable and settings.rcapture.active and settings.rcapture.biz ~= -1 then
      if dialog == 1 and style == 3 and title == "{FFFFFF}Авторизация" then
        if settings.rcapture.password ~= "" and auf_count < 2 then
          sampSendDialogResponse(dialog, 1, 0, settings.rcapture.password)
          auf_count = auf_count + 1
        end
        table.insert(tempThreads, lua_thread.create(function()
          local res, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
          while sampGetPlayerScore(id) == 0 do
            wait(0)
          end
          antiFlood()
          sampSendChat("/capture")
          wait(300)
          if settings.rcapture.active then
            sampSendChat("/capture")
            settings.rcapture.biz = -1
            settings.rcapture.password = ""
            settings.rcapture.active = false
            inicfg.save(settings, "edith")
            addOneOffSound(0.0, 0.0, 0.0, 1052)
          end
        end))
      end
      if dialog == 212 then
        sampSendDialogResponse(212, 1, settings.rcapture.biz, -1)
        settings.rcapture.biz = -1
        settings.rcapture.password = ""
        settings.rcapture.active = false
        inicfg.save(settings, "edith")
        addOneOffSound(0.0, 0.0, 0.0, 1052)
        return false
      end
    end
  end

  local onSendDialogResponse = function(dialogId, button, listboxId, input)
    if r_sel and dialogId == 212 then
      if button == 1 then
        settings.rcapture.biz = listboxId
        inicfg.save(settings, "edith")
        r_sel = false
        return false
      end
    end
  end

  local onSendChat = function(message)
    sleep = os.clock() * 1000
  end

  local onSendCommand = function(cmd)
    sleep = os.clock() * 1000
  end

  return {
    main = mainThread,
    getMenu = getMenu,
    desc = description,
    enable = enableAll,
    disable = disableAll,
    defaults = defaults,
    onShowDialog = onShowDialog,
    register = register,
    onSendDialogResponse = onSendDialogResponse,
    onSendChat = onSendChat,
    onSendCommand = onSendCommand
  }
end
--------------------------------------------------------------------------------
-------------------------------------GETGUN-------------------------------------
--------------------------------------------------------------------------------
function getgunModule()
  --gg и ggtable должны быть глобальными, чтобы сторож мог считать оружие, взятое модулем гетгана
  --это костыль, так как sampSendDialogResponse минует хуки почему-то
  gg = false
  ggtable = {}

  local mainThread = function()
    while true do
      wait(100)
      gg = false
      while settings.getgun.enable and getActiveInterior() == 11 do
        wait(100)
        if
        wasKeyPressed(settings.getgun.key) and sampIsChatInputActive() == false and isSampfuncsConsoleActive() == false and
                sampIsDialogActive() == false
        then
          local res, handle = getCharPlayerIsTargeting(playerHandle)
          if res then
            resid, getgunid = sampGetPlayerIdByCharHandle(handle)
            if resid then
              ggtable["deagle"] = settings.getgun.deagle
              ggtable["shotgun"] = settings.getgun.shotgun
              ggtable["smg"] = settings.getgun.smg
              ggtable["ak47"] = settings.getgun.ak47
              ggtable["m4a1"] = settings.getgun.m4a1
              ggtable["rifle"] = settings.getgun.rifle
              gg = true
              sampSendChat("/getgun " .. getgunid)
            end
          else
            ggtable["deagle"] = settings.getgun.deagle
            ggtable["shotgun"] = settings.getgun.shotgun
            ggtable["smg"] = settings.getgun.smg
            ggtable["ak47"] = settings.getgun.ak47
            ggtable["m4a1"] = settings.getgun.m4a1
            ggtable["rifle"] = settings.getgun.rifle
            gg = true
            sampSendChat("/getgun")
          end
        end
      end
    end
  end
  
  local changegetgunhotkey = function()
    sampShowDialog(
            989,
            "Изменение горячей клавиши активации getgun",
            'Нажмите "Окей", после чего нажмите нужную клавишу.\nНастройки будут изменены.',
            "Окей",
            "Закрыть"
    )
    while sampIsDialogActive(989) do
      wait(100)
    end
    local resultMain, buttonMain, typ = sampHasDialogRespond(989)
    if buttonMain == 1 then
      while ke1y == nil do
        wait(100)
        for i = 1, 200 do
          if isKeyDown(i) then
            settings.getgun.key = i
            sampAddChatMessage("Установлена новая горячая клавиша - " .. key.id_to_name(i), -1)
            addOneOffSound(0.0, 0.0, 0.0, 1052)
            inicfg.save(settings, "edith")
            ke1y = 1
            break
          end
        end
      end
      ke1y = nil
    end
  end

  local getMenu = function()
    return {
      title = "{7ef3fa}* " .. (settings.getgun.enable and "{00ff66}" or "{ff0000}") .. "GETGUN",
      submenu = {
        {
          title = "Информация о модуле",
          onclick = function()
            sampShowDialog(
                    0,
                    "{7ef3fa}/edith v." .. thisScript().version .. ' - информация о модуле {00ff66}"GETGUN"',
                    "{00ff66}GETGUN{ffffff}\n{ffffff}Тупа гетгун\n\nПо нажатию хоткея {00ccff}" ..
                            tostring(key.id_to_name(settings.getgun.key)) ..
                            "{ffffff} берется оружие в баре.\nРаботает самым быстрым способом.\nЦелишься короче перед нажатием чтобы выдать таргету.\nВ настройках можно изменить хоткей и вкл/выкл модуль",
                    "Окей"
            )
          end
        },
        {
          title = "Вкл/выкл модуля: " .. tostring(settings.getgun.enable),
          onclick = function()
            settings.getgun.enable = not settings.getgun.enable
            inicfg.save(settings, "edith")
          end
        },
        {
          title = " "
        },
        {
          title = "{AAAAAA}НАБОР ОРУЖИЯ"
        },
        {
          title = "* DEAGLE: " .. tostring(settings.getgun.deagle),
          onclick = function()
            sampShowDialog(
                    9827,
                    "Количество дигла.",
                    string.format("Введите количество дигла в наборе."),
                    "Выбрать",
                    "Закрыть",
                    1
            )
            sampSetCurrentDialogEditboxText(settings.getgun.deagle)
            while sampIsDialogActive() do
              wait(100)
            end
            local result, button, list, input = sampHasDialogRespond(9827)
            if button == 1 then
              if
              tonumber(sampGetCurrentDialogEditboxText(9827)) ~= nil and
                      tonumber(sampGetCurrentDialogEditboxText(987)) >= 0 and
                      tonumber(sampGetCurrentDialogEditboxText(987)) < 10
              then
                settings.getgun.deagle = tonumber(sampGetCurrentDialogEditboxText(9827))
              end
            end
            inicfg.save(settings, "edith")
          end
        },
        {
          title = "* SHOTGUN: " .. tostring(settings.getgun.shotgun),
          onclick = function()
            sampShowDialog(
                    9827,
                    "Количество дигла.",
                    string.format("Введите количество дигла в наборе."),
                    "Выбрать",
                    "Закрыть",
                    1
            )
            sampSetCurrentDialogEditboxText(settings.getgun.shotgun)
            while sampIsDialogActive() do
              wait(100)
            end
            local result, button, list, input = sampHasDialogRespond(9827)
            if button == 1 then
              if
              tonumber(sampGetCurrentDialogEditboxText(9827)) ~= nil and
                      tonumber(sampGetCurrentDialogEditboxText(987)) >= 0 and
                      tonumber(sampGetCurrentDialogEditboxText(987)) < 10
              then
                settings.getgun.shotgun = tonumber(sampGetCurrentDialogEditboxText(9827))
              end
            end
            inicfg.save(settings, "edith")
          end
        },
        {
          title = "* SMG: " .. tostring(settings.getgun.smg),
          onclick = function()
            sampShowDialog(
                    9827,
                    "Количество дигла.",
                    string.format("Введите количество дигла в наборе."),
                    "Выбрать",
                    "Закрыть",
                    1
            )
            sampSetCurrentDialogEditboxText(settings.getgun.smg)
            while sampIsDialogActive() do
              wait(100)
            end
            local result, button, list, input = sampHasDialogRespond(9827)
            if button == 1 then
              if
              tonumber(sampGetCurrentDialogEditboxText(9827)) ~= nil and
                      tonumber(sampGetCurrentDialogEditboxText(987)) >= 0 and
                      tonumber(sampGetCurrentDialogEditboxText(987)) < 10
              then
                settings.getgun.smg = tonumber(sampGetCurrentDialogEditboxText(9827))
              end
            end
            inicfg.save(settings, "edith")
          end
        },
        {
          title = "* AK47: " .. tostring(settings.getgun.ak47),
          onclick = function()
            sampShowDialog(
                    9827,
                    "Количество дигла.",
                    string.format("Введите количество дигла в наборе."),
                    "Выбрать",
                    "Закрыть",
                    1
            )
            sampSetCurrentDialogEditboxText(settings.getgun.ak47)
            while sampIsDialogActive() do
              wait(100)
            end
            local result, button, list, input = sampHasDialogRespond(9827)
            if button == 1 then
              if
              tonumber(sampGetCurrentDialogEditboxText(9827)) ~= nil and
                      tonumber(sampGetCurrentDialogEditboxText(987)) >= 0 and
                      tonumber(sampGetCurrentDialogEditboxText(987)) < 10
              then
                settings.getgun.ak47 = tonumber(sampGetCurrentDialogEditboxText(9827))
              end
            end
            inicfg.save(settings, "edith")
          end
        },
        {
          title = "* M4A1: " .. tostring(settings.getgun.m4a1),
          onclick = function()
            sampShowDialog(
                    9827,
                    "Количество дигла.",
                    string.format("Введите количество дигла в наборе."),
                    "Выбрать",
                    "Закрыть",
                    1
            )
            sampSetCurrentDialogEditboxText(settings.getgun.m4a1)
            while sampIsDialogActive() do
              wait(100)
            end
            local result, button, list, input = sampHasDialogRespond(9827)
            if button == 1 then
              if
              tonumber(sampGetCurrentDialogEditboxText(9827)) ~= nil and
                      tonumber(sampGetCurrentDialogEditboxText(987)) >= 0 and
                      tonumber(sampGetCurrentDialogEditboxText(987)) < 10
              then
                settings.getgun.m4a1 = tonumber(sampGetCurrentDialogEditboxText(9827))
              end
            end
            inicfg.save(settings, "edith")
          end
        },
        {
          title = "* RIFLE: " .. tostring(settings.getgun.rifle),
          onclick = function()
            sampShowDialog(
                    9827,
                    "Количество дигла.",
                    string.format("Введите количество дигла в наборе."),
                    "Выбрать",
                    "Закрыть",
                    1
            )
            sampSetCurrentDialogEditboxText(settings.getgun.rifle)
            while sampIsDialogActive() do
              wait(100)
            end
            local result, button, list, input = sampHasDialogRespond(9827)
            if button == 1 then
              if
              tonumber(sampGetCurrentDialogEditboxText(9827)) ~= nil and
                      tonumber(sampGetCurrentDialogEditboxText(987)) >= 0 and
                      tonumber(sampGetCurrentDialogEditboxText(987)) < 10
              then
                settings.getgun.rifle = tonumber(sampGetCurrentDialogEditboxText(9827))
              end
            end
            inicfg.save(settings, "edith")
          end
        },
        {
          title = " "
        },
        {
          title = "Изменить горячую клавишу",
          onclick = function()
            table.insert(tempThreads, lua_thread.create(changegetgunhotkey))
          end
        }
      }
    }
  end

  local description = function()
    return "{7ef3fa}* " .. (settings.getgun.enable and "{00ff66}" or "{ff0000}") .. "GETGUN - {ffffff}Быстрое взятие набора оружия по нажатию кнопки {00ccff}" ..
            tostring(key.id_to_name(settings.getgun.key)) ..
            "{ffffff}, выдача по таргету."
  end

  local enableAll = function()
    settings.getgun.enable = true
  end

  local disableAll = function()
    settings.getgun.enable = false
  end

  local defaults = {
    enable = true,
    key = 78,
    deagle = 2,
    shotgun = 0,
    smg = 0,
    ak47 = 0,
    m4a1 = 0,
    rifle = 1
  }

  local onShowDialog = function(dialog, style, title, button1, button2, text)
    if dialog == 123 and gg then
      if ggtable["deagle"] > 0 then
        ggtable["deagle"] = ggtable["deagle"] - 1
        sampSendDialogResponse(123, 1, 0, -1)
        return false
      end
      if ggtable["shotgun"] > 0 then
        ggtable["shotgun"] = ggtable["shotgun"] - 1
        sampSendDialogResponse(123, 1, 1, -1)
        return false
      end
      if ggtable["smg"] > 0 then
        ggtable["smg"] = ggtable["smg"] - 1
        sampSendDialogResponse(123, 1, 2, -1)
        return false
      end
      if ggtable["ak47"] > 0 then
        ggtable["ak47"] = ggtable["ak47"] - 1
        sampSendDialogResponse(123, 1, 3, -1)
        return false
      end
      if ggtable["m4a1"] > 0 then
        ggtable["m4a1"] = ggtable["m4a1"] - 1
        sampSendDialogResponse(123, 1, 4, -1)
        return false
      end
      if ggtable["rifle"] > 0 then
        ggtable["rifle"] = ggtable["rifle"] - 1
        sampSendDialogResponse(123, 1, 5, -1)
        return false
      end
      gg = false
      return false
    end
  end

  return {
    main = mainThread,
    getMenu = getMenu,
    desc = description,
    enable = enableAll,
    disable = disableAll,
    defaults = defaults,
    onShowDialog = onShowDialog
  }
end
--------------------------------------------------------------------------------
-------------------------------------LIKER--------------------------------------
--------------------------------------------------------------------------------
function likerModule()
  local like_nicks = {}
  local like_id = -1
  local liker_active = false

  local sleep = 0

  local asodkas, licenseid = sampGetPlayerIdByCharHandle(PLAYER_PED)
  local licensenick = sampGetPlayerNickname(licenseid)

  local antiFlood = function()
    repeat
      wait(100)
      local res, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
      local ms = math.ceil(os.clock() * 1000 - sleep)
    until ms > 1200 and sampGetPlayerScore(id) >= 1 and not sampIsDialogActive() and not sampIsChatInputActive()
  end

  local sampGetPlayerIdByNickname = function(nick)
    local _, myid = sampGetPlayerIdByCharHandle(playerPed)
    if tostring(nick) == sampGetPlayerNickname(myid) then
      return myid
    end
    for i = 0, 1000 do
      if sampIsPlayerConnected(i) and sampGetPlayerNickname(i) == tostring(nick) then
        return i
      end
    end
    return nil
  end

  local like = function(id)
    wait(100)
    if settings.rcapture.active then
      wait(200)
    end
    antiFlood()
    sampSendChat('/like ' .. id)
  end

  local mainThread = function()
    if settings.liker[licensenick] == nil then
      settings.liker[licensenick] = 0
      inicfg.save(settings, "edith")
    end
    repeat
      wait(5000)
      local res, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
      local ms = math.ceil(os.clock() * 1000 - sleep)
    until settings.liker[licensenick] + 3600 < os.time(os.date("!*t")) and ms > 1200 and sampGetPlayerScore(id) >= 1 and not sampIsDialogActive() and not sampIsChatInputActive()

    while true do
      wait(100)
      if settings.liker.enable then
        liker_active = true
        for k, v in pairs(like_nicks) do
          like_id = sampGetPlayerIdByNickname(v)
          if like_id and liker_active then
            settings.liker[licensenick] = os.time(os.date("!*t"))
            inicfg.save(settings, "edith")
            like(like_id)
          end
        end
        wait(10000)
        liker_active = false
        wait(3660000)
      end
    end
  end

  local getMenu = function()
    return {
      title = "{7ef3fa}* " .. (settings.liker.enable and "{00ff66}" or "{ff0000}") .. "LIKER",
      submenu = {
        {
          title = "Информация о модуле",
          onclick = function()
            sampShowDialog(
                    0,
                    "{7ef3fa}/edith v." .. thisScript().version .. ' - информация о модуле {00ff66}"LIKER"',
                    "{00ff66}LIKER{ffffff}\nОбменивается лайками между игроками, имеющими доступ к EDITH.",
                    "Окей"
            )
          end
        },
        {
          title = "Включить: " .. tostring(settings.liker.enable),
          onclick = function()
            settings.liker.enable = not settings.liker.enable
            inicfg.save(settings, "edith")
          end
        }
      }
    }
  end

  local description = function()
    return "{7ef3fa}* " .. (settings.liker.enable and "{00ff66}" or "{ff0000}") .. "LIKER - {ffffff}Автообмен /like (рп рейтинг) между пользователями скрипта."
  end

  local enableAll = function()
    settings.liker.enable = true
  end

  local disableAll = function()
    settings.liker.enable = false
  end

  local defaults = {
    enable = true
  }

  local onServerMessage = function(color, text)
    if settings.liker.enable then
      if liker_active then
        if text == " Рейтинг игрока должен быть ниже чем у вас" or text == " Вы недавно уже изменяли рейтинг этому игроку" then
          return false
        end
        if text == " Повторите попытку через 1 час" then
          liker_active = false
          settings.liker[licensenick] = os.time(os.date("!*t"))
          inicfg.save(settings, "edith")
          return false
        end
      end
    end
  end

  local onSendChat = function(message)
    sleep = os.clock() * 1000
  end

  local onSendCommand = function(cmd)
    sleep = os.clock() * 1000
  end

  local process = function(data)
    like_nicks = data
  end

  return {
    main = mainThread,
    getMenu = getMenu,
    desc = description,
    enable = enableAll,
    disable = disableAll,
    defaults = defaults,
    onServerMessage = onServerMessage,
    onSendChat = onSendChat,
    onSendCommand = onSendCommand,

    process = process
  }
end
--------------------------------------------------------------------------------
----------------------------------CHANGEWEAPON----------------------------------
--------------------------------------------------------------------------------
function changeweaponModule()
  local car = 0
  local driver = 0
  local weapon = 0
  local start_while = os.clock()
  local trig = false

  local mainThread = function()
    while true do
      wait(100)
      if settings.changeweapon.enable then
        if isCharInAnyCar(playerPed) then
          car = storeCarCharIsInNoSave(playerPed)
          driver = getDriverOfCar(car)
          if driver ~= playerPed then
            if not sampIsChatInputActive() and not sampIsDialogActive() and not sampIsScoreboardOpen() and not isSampfuncsConsoleActive() and (wasKeyPressed(219) or wasKeyPressed(221)) then
              local div = 0
              if wasKeyPressed(219) then
                div = -1
              end
              if wasKeyPressed(221) then
                div = 1
              end
              weapon = getCurrentCharWeapon(playerPed)
              weapon = weapon + div

              if weapon == 24 then
                weapon = weapon + div
              end
              start_while = os.clock()
              trig = false
              while getAmmoInCharWeapon(playerPed, weapon) <= 0 or weapon >= 50 or weapon <= 22 do
                wait(0)
                weapon = weapon + div
                if weapon == 24 then
                  weapon = weapon + div
                end
                if div == 1 and weapon > 50 then
                  weapon = 0
                end
                if div == -1 and weapon < 0 then
                  weapon = 50
                end
                if os.clock() - start_while > 1 then
                  trig = true
                  break
                end
              end
              if not trig then
                bs = raknetNewBitStream()
                raknetBitStreamWriteInt32(bs, weapon)

                raknetBitStreamWriteInt32(bs, 0)
                raknetEmulRpcReceiveBitStream(22, bs)
                raknetDeleteBitStream(bs)
              end
            end
          end
        end
      end
    end
  end

  local getMenu = function()
    return {
      title = "{7ef3fa}* " .. (settings.changeweapon.enable and "{00ff66}" or "{ff0000}") .. "CHANGEWEAPON",
      submenu = {
        {
          title = "Информация о модуле",
          onclick = function()
            sampShowDialog(
                    0,
                    "{7ef3fa}/edith v." .. thisScript().version .. ' - информация о модуле {00ff66}"CHANGEWEAPON"',
                    "{00ff66}CHANGEWEAPON{ffffff}\n{ffffff}Если включен, то на пассажирке можно менять оружие через {00ccff}[{ffffff} и {00ccff}]{ffffff}.",
                    "Окей"
            )
          end
        },
        {
          title = "Включить: " .. tostring(settings.changeweapon.enable),
          onclick = function()
            settings.changeweapon.enable = not settings.changeweapon.enable
            inicfg.save(settings, "edith")
          end
        }
      }
    }
  end

  local description = function()
    return "{7ef3fa}* " .. (settings.changeweapon.enable and "{00ff66}" or "{ff0000}") .. "CHANGEWEAPON - {ffffff}Меняет слот оружия на пассажирке. Активация: {00ccff}[{ffffff} и {00ccff}]{ffffff}."
  end

  local enableAll = function()
    settings.changeweapon.enable = true
  end

  local disableAll = function()
    settings.changeweapon.enable = false
  end

  local defaults = {
    enable = false
  }

  return {
    main = mainThread,
    getMenu = getMenu,
    desc = description,
    enable = enableAll,
    disable = disableAll,
    defaults = defaults
  }
end
--------------------------------------------------------------------------------
-----------------------------------HIDEWEAPON-----------------------------------
--------------------------------------------------------------------------------
function hideweaponModule()
  local driveby_enable = false
  local car = 0
  local driver = 0
  local driveby_weapon = 0
  local driveby_ammo = 0

  local mainThread = function()
    while true do
      wait(100)
      if settings.hideweapon.enable then
        if isCharInAnyCar(playerPed) then
          car = storeCarCharIsInNoSave(playerPed)
          driver = getDriverOfCar(car)
          if driver ~= playerPed then
            if not sampIsChatInputActive() and not sampIsDialogActive() and not sampIsScoreboardOpen() and not isSampfuncsConsoleActive() and wasKeyPressed(72) then
              if driveby_enable then
                driveby_weapon = getCurrentCharWeapon(playerPed)
                driveby_ammo = getAmmoInCharWeapon(playerPed, getCurrentCharWeapon(playerPed))
                if driveby_ammo > 1 then
                  wait(200)
                  setCharAmmo(playerPed, driveby_weapon, 1)
                  wait(100)
                  setVirtualKeyDown(0xA2, true)
                  wait(250)
                  setVirtualKeyDown(0xA2, false)
                  wait(800)
                  if getAmmoInCharWeapon(playerPed, getCurrentCharWeapon(playerPed)) == 0 then
                    setCharAmmo(playerPed, driveby_weapon, driveby_ammo - 1)
                  else
                    setCharAmmo(playerPed, driveby_weapon, driveby_ammo)
                  end
                  driveby_enable = false
                else
                  driveby_enable = false
                end
              else
                --taskDriveBy(playerPed, - 1, - 1, 0.0, 0.0, 0.0, 900.0, 4, 0, 0)
                driveby_enable = true
              end
            end
          end
        else
          driveby_enable = false
        end
      end
    end
  end

  local getMenu = function()
    return {
      title = "{7ef3fa}* " .. (settings.hideweapon.enable and "{00ff66}" or "{ff0000}") .. "HIDEWEAPON",
      submenu = {
        {
          title = "Информация о модуле",
          onclick = function()
            sampShowDialog(
                    0,
                    "{7ef3fa}/edith v." .. thisScript().version .. ' - информация о модуле {00ff66}"HIDEWEAPON"',
                    "{00ff66}HIDEWEAPON{ffffff}\n{ffffff}Убирать/доставать driveBy на H на пассажирке, нужен новый самп луа, если не работает.",
                    "Окей"
            )
          end
        },
        {
          title = "Включить: " .. tostring(settings.hideweapon.enable),
          onclick = function()
            settings.hideweapon.enable = not settings.hideweapon.enable
            inicfg.save(settings, "edith")
          end
        }
      }
    }
  end

  local description = function()
    return "{7ef3fa}* " .. (settings.hideweapon.enable and "{00ff66}" or "{ff0000}") .. "HIDEWEAPON - {00ccff}H{ffffff} на пассажирке, чтобы убрать оружие, если вы его достали."
  end

  local enableAll = function()
    settings.hideweapon.enable = true
  end

  local disableAll = function()
    settings.hideweapon.enable = false
  end

  local defaults = {
    enable = false
  }

  return {
    main = mainThread,
    getMenu = getMenu,
    desc = description,
    enable = enableAll,
    disable = disableAll,
    defaults = defaults
  }
end
--------------------------------------------------------------------------------
------------------------------------GZ_CHECK------------------------------------
--------------------------------------------------------------------------------
function gzcheckModule()
  local zones = {}
  local act_zones = {}
  local font12 = renderCreateFont("Impact", 12, 4)

  local mainThread = function()
    local x_screen, y_screen = getScreenResolution()
    while true do
      wait(100)
      while settings.gzcheck.enable do
        wait(0)
        for k, v in pairs(act_zones) do
          if v['start']["x"] ~= nil and v['start']["y"] ~= nil then
            if isCharInArea2d(playerPed, v['start']["x"], v['start']["y"], v['end']["x"], v['end']["y"], false) then
              renderDrawBox(x_screen * 0.5 - 90, y_screen * 0.95, 180, 60, 0xFFC70000)
              renderFontDrawText(font12, "В КВАДРАТЕ", x_screen * 0.5 - 75, y_screen * 0.96, -1)
            end
          end
        end
      end
    end
  end

  local getMenu = function()
    return {
      title = "{7ef3fa}* " .. (settings.gzcheck.enable and "{00ff66}" or "{ff0000}") .. "GZCHECK",
      submenu = {
        {
          title = "Информация о модуле",
          onclick = function()
            sampShowDialog(
                    0,
                    "{7ef3fa}/edith v." .. thisScript().version .. ' - информация о модуле {00ff66}"GZCHECK"',
                    "{00ff66}GZCHECK{ffffff}\n{ffffff}Рендерит квадрат на экране, когда вы в квадрате.\nЕсли вы рестартили скрипт без реконнетка, работать не будет.",
                    "Окей"
            )
          end
        },
        {
          title = "Включить: " .. tostring(settings.gzcheck.enable),
          onclick = function()
            settings.gzcheck.enable = not settings.gzcheck.enable
            inicfg.save(settings, "edith")
          end
        }
      }
    }
  end

  local description = function()
    return "{7ef3fa}* " .. (settings.gzcheck.enable and "{00ff66}" or "{ff0000}") .. "GZCHECK - {ffffff}Рендерит текст на экран, если вы в мигающем квадрате."
  end

  local enableAll = function()
    settings.gzcheck.enable = true
  end

  local disableAll = function()
    settings.gzcheck.enable = false
  end

  local defaults = {
    enable = false
  }

  local onCreateGangZone = function(zoneId, squareStart, squareEnd, color)
    zones[zoneId] = {}
    zones[zoneId]["start"] = squareStart
    zones[zoneId]["end"] = squareEnd
    zones[zoneId]["color"] = color
  end

  local onGangZoneDestroy = function(zoneId)
    zones[zoneId] = nil
    act_zones[zoneId] = nil
  end

  local onGangZoneFlash = function(zoneId, color)
    if zones[zoneId] then
      act_zones[zoneId] = zones[zoneId]
    end
  end

  local onGangZoneStopFlash = function(zoneId)
    if act_zones[zoneId] then
      act_zones[zoneId] = nil
    end
  end

  return {
    main = mainThread,
    getMenu = getMenu,
    desc = description,
    enable = enableAll,
    disable = disableAll,
    defaults = defaults,
    onCreateGangZone = onCreateGangZone,
    onGangZoneDestroy = onGangZoneDestroy,
    onGangZoneFlash = onGangZoneFlash,
    onGangZoneStopFlash = onGangZoneStopFlash
  }
end
--------------------------------------------------------------------------------
-------------------------------------STOROJ-------------------------------------
--------------------------------------------------------------------------------
function storojModule()
  local st_dg, st_sg, st_smg, st_ak47, st_m4, st_rf, tk_dg, tk_sg, tk_smg, tk_ak47, tk_m4, tk_rf = 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  local check_bonus_storoj = 0
  local bonus_getgun = 1

  local curWkavAllText = ""
  local curWkavDayText = ""
  local last_upd = 0

  local Set = function(list)
    local set = {}
    for _, l in ipairs(list) do
      set[l] = true
    end
    return set
  end

  local skins_bikers = Set { 247, 248, 254, 100, 181, 178, 246 }

  local sleep = 0

  local antiFlood = function()
    repeat
      wait(100)
      local res, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
      local ms = math.ceil(os.clock() * 1000 - sleep)
    until ms > 1200 and sampGetPlayerScore(id) >= 1 and not sampIsDialogActive() and not sampIsChatInputActive()
  end

  local createWkav = function()
    if os.clock() - last_upd > 3 then
      last_upd = os.clock()

      if getActiveInterior() ~= 11 then
        if sampIs3dTextDefined(802) then
          sampDestroy3dText(802)
        end
        if sampIs3dTextDefined(803) then
          sampDestroy3dText(803)
        end
      else

        if settings.storoj.enable then
          if settings.lost_today.date ~= os.date("%x") then
            settings.lost_today.date = os.date("%x")
            settings.lost_today.taken = 0
            settings.lost_today.left = 0
            settings.lost_today.st_dg = 0
            settings.lost_today.st_sg = 0
            settings.lost_today.st_smg = 0
            settings.lost_today.st_ak47 = 0
            settings.lost_today.st_m4 = 0
            settings.lost_today.st_rf = 0
            settings.lost_today.tk_dg = 0
            settings.lost_today.tk_sg = 0
            settings.lost_today.tk_smg = 0
            settings.lost_today.tk_ak47 = 0
            settings.lost_today.tk_m4 = 0
            settings.lost_today.tk_rf = 0
            inicfg.save(settings, "edith")
          end
          local text11 = string.format(
                  "Шкафчик с оружием\nБонусы на патроны: x%s\n\nВы потеряли за всё время:\n\nОружие|проебано|взято\nDeagle: %s/%s\n Shotgun: %s/%s\nSMG: %s/%s\nAK47: %s/%s\nM4: %s/%s\nRifle: %s/%s\n\nМатериалов взято со склада: %s\nПотрачено в бою/осталось на руках: %s\nМатериалов проебано: %s\n\nЭффективность: %.1f%%",
                  bonus_getgun,
                  settings.lost_alltime.st_dg,
                  settings.lost_alltime.tk_dg,
                  settings.lost_alltime.st_sg,
                  settings.lost_alltime.tk_sg,
                  settings.lost_alltime.st_smg,
                  settings.lost_alltime.tk_smg,
                  settings.lost_alltime.st_ak47,
                  settings.lost_alltime.tk_ak47,
                  settings.lost_alltime.st_m4,
                  settings.lost_alltime.tk_m4,
                  settings.lost_alltime.st_rf,
                  settings.lost_alltime.tk_rf,
                  settings.lost_alltime.taken,
                  settings.lost_alltime.taken - settings.lost_alltime.left,
                  settings.lost_alltime.left,
                  (settings.lost_alltime.taken - settings.lost_alltime.left) * 100 / settings.lost_alltime.taken
          )

          if curWkavAllText ~= text11 then
            sampCreate3dTextEx(802, text11, 0xFFFFFFFF, 244.5, 0.6, 1502.3, 4.0, false, -1, -1)
            curWkavAllText = text11
          end

          local text22 = string.format(
                  "Шкафчик с оружием\nБонусы на патроны: x%s\n\nВы потеряли сегодня:\n\nОружие|проебано|взято\nDeagle: %s/%s\n Shotgun: %s/%s\nSMG: %s/%s\nAK47: %s/%s\nM4: %s/%s\nRifle: %s/%s\n\nМатериалов взято со склада: %s\nПотрачено в бою/осталось на руках: %s\nМатериалов проебано: %s\n\nЭффективность: %.1f%%",
                  bonus_getgun,
                  settings.lost_today.st_dg,
                  settings.lost_today.tk_dg,
                  settings.lost_today.st_sg,
                  settings.lost_today.tk_sg,
                  settings.lost_today.st_smg,
                  settings.lost_today.tk_smg,
                  settings.lost_today.st_ak47,
                  settings.lost_today.tk_ak47,
                  settings.lost_today.st_m4,
                  settings.lost_today.tk_m4,
                  settings.lost_today.st_rf,
                  settings.lost_today.tk_rf,
                  settings.lost_today.taken,
                  settings.lost_today.taken - settings.lost_today.left,
                  settings.lost_today.left,
                  (settings.lost_today.taken - settings.lost_today.left) * 100 / settings.lost_today.taken
          )
          if curWkavDayText ~= text22 then
            sampCreate3dTextEx(803, text22, 0xFFFFFFFF, 244.5, 1.9, 1502.3, 4.0, false, -1, -1)
            curWkavDayText = text22
          end
        end
      end
    end
  end

  local isArenaActive = function()
    if getActiveInterior() == 0 then
      local x, y, z = getCharCoordinates(playerPed)
      if z > 500 then
        return true
      else
        return false
      end
    else
      return false
    end
  end

  local mainThread = function()
    while true do
      wait(200)
      if settings.storoj.enable then
        if not isCharDead(playerPed) then
          if hasCharGotWeapon(playerPed, 24) then
            --deagle
            st_dg = getAmmoInCharWeapon(playerPed, 24)
          else
            st_dg = 0
          end

          if hasCharGotWeapon(playerPed, 25) then
            --shotgun
            st_sg = getAmmoInCharWeapon(playerPed, 25)
          else
            st_sg = 0
          end

          if hasCharGotWeapon(playerPed, 29) then
            --mp5
            st_smg = getAmmoInCharWeapon(playerPed, 29)
          else
            st_smg = 0
          end

          if hasCharGotWeapon(playerPed, 30) then
            --ak47
            st_ak47 = getAmmoInCharWeapon(playerPed, 30)
          else
            st_ak47 = 0
          end

          if hasCharGotWeapon(playerPed, 31) then
            --m4
            st_m4 = getAmmoInCharWeapon(playerPed, 31)
          else
            st_m4 = 0
          end

          if hasCharGotWeapon(playerPed, 33) then
            --rifle
            st_rf = getAmmoInCharWeapon(playerPed, 33)
          else
            st_rf = 0
          end
        else
          if (st_dg > 0 or st_sg > 0 or st_smg > 0 or st_ak47 > 0 or st_m4 > 0 or st_rf > 0) and not isArenaActive() then
            local skin = getCharModel(playerPed)
            if skin and skins_bikers[skin] then
              if settings.storoj.report then
                sampAddChatMessage(string.format("{7ef3fa}[EDITH]: {ffffff}Вы трагически погибли :(( {7ef3fa}dg: %s/%s, sg: %s/%s, smg: %s/%s, ak47: %s/%s, m4: %s/%s, rf: %s/%s", st_dg, tk_dg, st_sg, tk_sg, st_smg, tk_smg, st_ak47, tk_ak47, st_m4, tk_m4, st_rf, tk_rf), -1)
                mat_dif = ((tk_dg - (tk_dg - st_dg)) * 3 + (tk_sg - (tk_sg - st_sg)) * 3 + (tk_smg - (tk_smg - st_smg)) * 2 + (tk_ak47 - (tk_ak47 - st_ak47)) * 3 + (tk_m4 - (tk_m4 - st_m4)) * 3 + (tk_rf - (tk_rf - st_rf)) * 5) / bonus_getgun
                if mat_dif > 0 then
                  sampAddChatMessage(string.format("{7ef3fa}[EDITH]: {ffffff}Вы умудрились проебать оружия на {ef3226}%s {ffffff}материалов", mat_dif), -1)
                end
              end
              if settings.lost_today.date ~= os.date("%x") then
                settings.lost_today.date = os.date("%x")
                settings.lost_today.taken = 0
                settings.lost_today.left = 0
                settings.lost_today.st_dg = 0
                settings.lost_today.st_sg = 0
                settings.lost_today.st_smg = 0
                settings.lost_today.st_ak47 = 0
                settings.lost_today.st_m4 = 0
                settings.lost_today.st_rf = 0
                settings.lost_today.tk_dg = 0
                settings.lost_today.tk_sg = 0
                settings.lost_today.tk_smg = 0
                settings.lost_today.tk_ak47 = 0
                settings.lost_today.tk_m4 = 0
                settings.lost_today.tk_rf = 0
              end
              settings.lost_today.left = settings.lost_today.left + (st_dg * 3 + st_sg * 3 + st_smg * 2 + st_ak47 * 3 + st_m4 * 3 + st_rf * 5) / bonus_getgun
              settings.lost_today.st_dg = settings.lost_today.st_dg + st_dg
              settings.lost_today.st_sg = settings.lost_today.st_sg + st_sg
              settings.lost_today.st_smg = settings.lost_today.st_smg + st_smg
              settings.lost_today.st_ak47 = settings.lost_today.st_ak47 + st_ak47
              settings.lost_today.st_m4 = settings.lost_today.st_m4 + st_m4
              settings.lost_today.st_rf = settings.lost_today.st_rf + st_rf

              settings.lost_alltime.left = settings.lost_alltime.left + (st_dg * 3 + st_sg * 3 + st_smg * 2 + st_ak47 * 3 + st_m4 * 3 + st_rf * 5) / bonus_getgun
              settings.lost_alltime.st_dg = settings.lost_alltime.st_dg + st_dg
              settings.lost_alltime.st_sg = settings.lost_alltime.st_sg + st_sg
              settings.lost_alltime.st_smg = settings.lost_alltime.st_smg + st_smg
              settings.lost_alltime.st_ak47 = settings.lost_alltime.st_ak47 + st_ak47
              settings.lost_alltime.st_m4 = settings.lost_alltime.st_m4 + st_m4
              settings.lost_alltime.st_rf = settings.lost_alltime.st_rf + st_rf

              inicfg.save(settings, "edith")
            end

            tk_dg, tk_sg, tk_smg, tk_ak47, tk_m4, tk_rf = 0, 0, 0, 0, 0, 0

            while isCharDead(playerPed) do
              wait(100)
            end
          end
        end

        createWkav()
      end
    end
  end

  local getMenu = function()
    return {
      title = "{7ef3fa}* " .. (settings.storoj.enable and "{00ff66}" or "{ff0000}") .. "WKAV",
      submenu = {
        {
          title = "Информация о модуле",
          onclick = function()
            sampShowDialog(
                    0,
                    "{7ef3fa}/edith v." .. thisScript().version .. ' - информация о модуле {00ff66}"WKAV"',
                    "{00ff66}WKAV{ffffff}\n{ffffff}Считает сколько вы проебали гана за всё время.\nУведомляет в чат при смерти, рендерит в оружейке статистику.\nВы сможете узнать насколько эффективно вы тратите склад.",
                    "Окей"
            )
          end
        },
        {
          title = " "
        },
        {
          title = "Включить: " .. tostring(settings.storoj.enable),
          onclick = function()
            settings.storoj.enable = not settings.storoj.enable
            if settings.storoj.enable then
              createWkav()
            else
              sampDestroy3dText(802)
              sampDestroy3dText(803)
            end

            inicfg.save(settings, "edith")
          end
        },
        {
          title = "Включить отчет в чат: " .. tostring(settings.storoj.report),
          onclick = function()
            settings.storoj.report = not settings.storoj.report
          end
        },
        {
          title = "Сбросить",
          onclick = function()
            settings.lost_today.date = os.date("%x")
            settings.lost_today.taken = 0
            settings.lost_today.left = 0
            settings.lost_today.st_dg = 0
            settings.lost_today.st_sg = 0
            settings.lost_today.st_smg = 0
            settings.lost_today.st_ak47 = 0
            settings.lost_today.st_m4 = 0
            settings.lost_today.st_rf = 0
            settings.lost_today.tk_dg = 0
            settings.lost_today.tk_sg = 0
            settings.lost_today.tk_smg = 0
            settings.lost_today.tk_ak47 = 0
            settings.lost_today.tk_m4 = 0
            settings.lost_today.tk_rf = 0
            settings.lost_alltime.taken = 0
            settings.lost_alltime.left = 0
            settings.lost_alltime.st_dg = 0
            settings.lost_alltime.st_sg = 0
            settings.lost_alltime.st_smg = 0
            settings.lost_alltime.st_ak47 = 0
            settings.lost_alltime.st_m4 = 0
            settings.lost_alltime.st_rf = 0
            settings.lost_alltime.tk_dg = 0
            settings.lost_alltime.tk_sg = 0
            settings.lost_alltime.tk_smg = 0
            settings.lost_alltime.tk_ak47 = 0
            settings.lost_alltime.tk_m4 = 0
            settings.lost_alltime.tk_rf = 0
            inicfg.save(settings, "edith")

            if settings.storoj.enable then
              createWkav()
            else
              sampDestroy3dText(802)
              sampDestroy3dText(803)
            end
          end
        }
      }
    }
  end

  local description = function()
    return "{7ef3fa}* " .. (settings.storoj.enable and "{00ff66}" or "{ff0000}") .. "WKAV - {ffffff}Считает сколько вы проебали гана за всё время. Отчёт в чат при смерти."
  end

  local enableAll = function()
    settings.storoj.enable = true
  end

  local disableAll = function()
    settings.storoj.enable = false
  end

  local defaults = {
    enable = true,
    report = true
  }

  local defaultsToday = {
    date = "00/00/00",
    taken = 0,
    left = 0,
    st_dg = 0,
    st_sg = 0,
    st_smg = 0,
    st_ak47 = 0,
    st_m4 = 0,
    st_rf = 0,
    tk_dg = 0,
    tk_sg = 0,
    tk_smg = 0,
    tk_ak47 = 0,
    tk_m4 = 0,
    tk_rf = 0
  }

  local defaultsAll = {
    taken = 0,
    left = 0,
    st_dg = 0,
    st_sg = 0,
    st_smg = 0,
    st_ak47 = 0,
    st_m4 = 0,
    st_rf = 0,
    tk_dg = 0,
    tk_sg = 0,
    tk_smg = 0,
    tk_ak47 = 0,
    tk_m4 = 0,
    tk_rf = 0
  }

  local onShowDialog = function(dialog, style, title, button1, button2, text)
    if dialog == 22 and title == "Бонусы" then
      for string in string.gmatch(text, '[^\n]+') do
        if string:find('Патронов у Байкеров	(.+)') then
          bonus_getgun = tonumber(string:match('Патронов у Байкеров	(.+)'))
          createWkav()
        end
      end
      if check_bonus_storoj == 2 then
        check_bonus_storoj = 0
        return false
      end
    end
    if gg ~= nil and ggtable ~= nil then
      if dialog == 123 and gg then
        if ggtable["deagle"] > 0 then
          tk_dg = tk_dg + 14

          if settings.storoj.enable then
            settings.lost_today.tk_dg = settings.lost_today.tk_dg + 14 * bonus_getgun
            settings.lost_alltime.tk_dg = settings.lost_alltime.tk_dg + 14 * bonus_getgun
            settings.lost_today.taken = settings.lost_today.taken + 42
            settings.lost_alltime.taken = settings.lost_alltime.taken + 42
            inicfg.save(settings, "edith")

            createWkav()
          end
        end
        if ggtable["shotgun"] > 0 then
          tk_sg = tk_sg + 10

          if settings.storoj.enable then
            settings.lost_today.tk_sg = settings.lost_today.tk_sg + 10 * bonus_getgun
            settings.lost_alltime.tk_sg = settings.lost_alltime.tk_sg + 10 * bonus_getgun
            settings.lost_today.taken = settings.lost_today.taken + 30
            settings.lost_alltime.taken = settings.lost_alltime.taken + 30
            inicfg.save(settings, "edith")

            createWkav()
          end
        end
        if ggtable["smg"] > 0 then
          tk_smg = tk_smg + 60

          if settings.storoj.enable then
            settings.lost_today.tk_smg = settings.lost_today.tk_smg + 60 * bonus_getgun
            settings.lost_alltime.tk_smg = settings.lost_alltime.tk_smg + 60 * bonus_getgun
            settings.lost_today.taken = settings.lost_today.taken + 120
            settings.lost_alltime.taken = settings.lost_alltime.taken + 120
            inicfg.save(settings, "edith")

            createWkav()
          end
        end
        if ggtable["ak47"] > 0 then
          tk_ak47 = tk_ak47 + 60

          if settings.storoj.enable then
            settings.lost_today.tk_ak47 = settings.lost_today.tk_ak47 + 60 * bonus_getgun
            settings.lost_alltime.tk_ak47 = settings.lost_alltime.tk_ak47 + 60 * bonus_getgun
            settings.lost_today.taken = settings.lost_today.taken + 180
            settings.lost_alltime.taken = settings.lost_alltime.taken + 180
            inicfg.save(settings, "edith")

            createWkav()
          end
        end
        if ggtable["m4a1"] > 0 then
          tk_m4 = tk_m4 + 100

          if settings.storoj.enable then
            settings.lost_today.tk_m4 = settings.lost_today.tk_m4 + 100 * bonus_getgun
            settings.lost_alltime.tk_m4 = settings.lost_alltime.tk_m4 + 100 * bonus_getgun
            settings.lost_today.taken = settings.lost_today.taken + 300
            settings.lost_alltime.taken = settings.lost_alltime.taken + 300
            inicfg.save(settings, "edith")

            createWkav()
          end
        end
        if ggtable["rifle"] > 0 then
          tk_rf = tk_rf + 10

          if settings.storoj.enable then
            settings.lost_today.tk_rf = settings.lost_today.tk_rf + 10 * bonus_getgun
            settings.lost_alltime.tk_rf = settings.lost_alltime.tk_rf + 10 * bonus_getgun
            settings.lost_today.taken = settings.lost_today.taken + 50
            settings.lost_alltime.taken = settings.lost_alltime.taken + 50
            inicfg.save(settings, "edith")

            createWkav()
          end
        end
      end
    end
  end

  local onSendDialogResponse = function(dialogId, button, listboxId, input)
    if dialogId == 123 and button == 1 then
      if string.find(input, "м.") then
        if settings.storoj.enable then
          if settings.lost_today.date ~= os.date("%x") then
            settings.lost_today.date = os.date("%x")
            settings.lost_today.taken = 0
            settings.lost_today.left = 0
            settings.lost_today.st_dg = 0
            settings.lost_today.st_sg = 0
            settings.lost_today.st_smg = 0
            settings.lost_today.st_ak47 = 0
            settings.lost_today.st_m4 = 0
            settings.lost_today.st_rf = 0
            settings.lost_today.tk_dg = 0
            settings.lost_today.tk_sg = 0
            settings.lost_today.tk_smg = 0
            settings.lost_today.tk_ak47 = 0
            settings.lost_today.tk_m4 = 0
            settings.lost_today.tk_rf = 0
          end
          inicfg.save(settings, "edith")
        end

        if listboxId == 0 then
          tk_dg = tk_dg + 14
          if settings.storoj.enable then

            settings.lost_today.tk_dg = settings.lost_today.tk_dg + 14 * bonus_getgun
            settings.lost_alltime.tk_dg = settings.lost_alltime.tk_dg + 14 * bonus_getgun
            settings.lost_today.taken = settings.lost_today.taken + 42
            settings.lost_alltime.taken = settings.lost_alltime.taken + 42
            inicfg.save(settings, "edith")
          end

        end
        if listboxId == 1 then
          tk_sg = tk_sg + 10
          if settings.storoj.enable then

            settings.lost_today.tk_sg = settings.lost_today.tk_sg + 10 * bonus_getgun
            settings.lost_alltime.tk_sg = settings.lost_alltime.tk_sg + 10 * bonus_getgun
            settings.lost_today.taken = settings.lost_today.taken + 30
            settings.lost_alltime.taken = settings.lost_alltime.taken + 30
            inicfg.save(settings, "edith")
          end
        end
        if listboxId == 2 then
          tk_smg = tk_smg + 60
          if settings.storoj.enable then

            settings.lost_today.tk_smg = settings.lost_today.tk_smg + 60 * bonus_getgun
            settings.lost_alltime.tk_smg = settings.lost_alltime.tk_smg + 60 * bonus_getgun
            settings.lost_today.taken = settings.lost_today.taken + 120
            settings.lost_alltime.taken = settings.lost_alltime.taken + 120
            inicfg.save(settings, "edith")
          end

        end
        if listboxId == 3 then
          tk_ak47 = tk_ak47 + 60
          if settings.storoj.enable then

            settings.lost_today.tk_ak47 = settings.lost_today.tk_ak47 + 60 * bonus_getgun
            settings.lost_alltime.tk_ak47 = settings.lost_alltime.tk_ak47 + 60 * bonus_getgun
            settings.lost_today.taken = settings.lost_today.taken + 180
            settings.lost_alltime.taken = settings.lost_alltime.taken + 180
            inicfg.save(settings, "edith")
          end

        end
        if listboxId == 4 then
          tk_m4 = tk_m4 + 100
          if settings.storoj.enable then

            settings.lost_today.tk_m4 = settings.lost_today.tk_m4 + 100 * bonus_getgun
            settings.lost_alltime.tk_m4 = settings.lost_alltime.tk_m4 + 100 * bonus_getgun
            settings.lost_today.taken = settings.lost_today.taken + 300
            settings.lost_alltime.taken = settings.lost_alltime.taken + 300
            inicfg.save(settings, "edith")
          end
        end
        if listboxId == 5 then
          tk_rf = tk_rf + 10
          if settings.storoj.enable then

            settings.lost_today.tk_rf = settings.lost_today.tk_rf + 100 * bonus_getgun
            settings.lost_alltime.tk_rf = settings.lost_alltime.tk_rf + 100 * bonus_getgun
            settings.lost_today.taken = settings.lost_today.taken + 100
            settings.lost_alltime.taken = settings.lost_alltime.taken + 100
            inicfg.save(settings, "edith")
          end
        end
        if settings.storoj.enable then
          createWkav()
        end
      end
    end
  end

  local onServerMessage = function(color, text)
    if check_bonus_storoj == 2 and color == -1 and text:find("Бонусы отключены") then
      check_bonus_storoj = 0
      return false
    end
    if check_bonus_storoj == 2 and color == -1 and text:find("Действует до") then
      return false
    end
  end

  local checkBoostInfo = function()
    wait(200)
    if settings.rcapture.active then
      wait(500)
    end
    antiFlood()
    check_bonus_storoj = 2
    sampSendChat('/boostinfo')
  end

  local onSendChat = function(message)
    sleep = os.clock() * 1000
  end

  local onSendCommand = function(cmd)
    sleep = os.clock() * 1000
  end

  return {
    main = mainThread,
    getMenu = getMenu,
    desc = description,
    enable = enableAll,
    disable = disableAll,
    defaults = defaults,
    onShowDialog = onShowDialog,
    onSendDialogResponse = onSendDialogResponse,
    onServerMessage = onServerMessage,
    defaultsToday = defaultsToday,
    defaultsAll = defaultsAll,
    checkboost = checkBoostInfo,
    onSendChat = onSendChat,
    onSendCommand = onSendCommand
  }
end
--------------------------------------------------------------------------------
-----------------------------------DRUGSMATS------------------------------------
--------------------------------------------------------------------------------
function drugsmatsModule()
  local check_bonus = 0
  local bonus_drugs = 1
  local check_inventory, drugs_timer, not_drugs_timer, renderText, d = 1, 0, false, {}, {}
  local ini = {}
  local font_drugs = 0

  local ip123, port123 = sampGetCurrentServerAddress()
  local result, PlayerId123 = sampGetPlayerIdByCharHandle(PLAYER_PED)
  local my_name = sampGetPlayerNickname(PlayerId123)

  local posX, posY = convertGameScreenCoordsToWindowScreenCoords(88.081993103027, 322.58331298828)

  local gramm = 0
  local X, Y, Height = 0, 0, 0
  local command, params = 0, 0

  local sleep = 0

  local antiFlood = function()
    repeat
      wait(100)
      local res, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
      local ms = math.ceil(os.clock() * 1000 - sleep)
    until ms > 1200 and sampGetPlayerScore(id) >= 1 and not sampIsDialogActive() and not sampIsChatInputActive()
  end

  local rubin_drugs_mats_GetMats = function()
    if settings.rcapture.active then
      wait(500)
    end
    antiFlood()

    if settings.drugsmats.enable then
      if ini[inikeys].inventory then
        check_inventory = 2
        sampSendChat('/inventory')
      end
    end
  end

  local rubin_drugs_mats_text_to_table = function()
    renderText[3] = {}
    renderText[4] = {}
    for str in string.gmatch(ini.lines.one:gsub("!n", "\n"), '[^\n]+') do
      renderText[3][#renderText[3] + 1] = str
    end
    for str in string.gmatch(ini.lines.two:gsub("!n", "\n"), '[^\n]+') do
      renderText[4][#renderText[4] + 1] = str
    end
  end

  local rubin_drugs_mats_ShowDialog = function(int, dtext, dinput, string_or_number, ini1, ini2)
    d[1], d[2], d[3], d[4], d[5], d[6] = int, dtext, dinput, string_or_number, ini1, ini2
    if int == 1 then
      dialogLine, dialogTextToList = {}, {}
      dialogLine[#dialogLine + 1] = '{59fc30} > Настройки для аккаунта\t{FFFFFF}' .. my_name
      dialogLine[#dialogLine + 1] = ' Скрипт\t' .. (ini[inikeys].run == true and "{59fc30}ON" or "{ff0000}OFF")
      dialogLine[#dialogLine + 1] = ' Проверка инвентаря [SRP/ERP]\t' .. (ini[inikeys].inventory == true and "{59fc30}ON" or "{ff0000}OFF")
      if ini[inikeys].run then
        dialogLine[#dialogLine + 1] = ' Сменить позицию\t'
      end
      dialogLine[#dialogLine + 1] = ' Серверная команда принять нарко\t' .. ini[inikeys].server_cmd
      dialogTextToList[#dialogLine] = "{FFFFFF}Введите команду которая используется для принятия наркотиков на вашем сервере!"
      dialogLine[#dialogLine + 1] = ' Базовое кд (без бонусов) в секундах\t' .. ini[inikeys].seconds
      dialogTextToList[#dialogLine] = "{FFFFFF}Введите базовое кд (без бонусов)"
      dialogLine[#dialogLine + 1] = ' Максимальное HP\t' .. ini[inikeys].hp
      dialogTextToList[#dialogLine] = "{FFFFFF}Введите ваше максимальное HP!"
      dialogLine[#dialogLine + 1] = ' Максимум грамм можно использовать\t' .. ini[inikeys].max_use_gram
      dialogTextToList[#dialogLine] = "{FFFFFF}Введите сколько максимум грамм наркотиков можно использовать за раз!"
      dialogLine[#dialogLine + 1] = ' HP дает 1 грамм наркотиков\t' .. ini[inikeys].hp_one_gram
      dialogTextToList[#dialogLine] = "{FFFFFF}Введите сколько HP дает 1 грамм наркотиков!"
      dialogLine[#dialogLine + 1] = '{59fc30} > Общие настройки\t'
      dialogLine[#dialogLine + 1] = ' Кнопка для использвания нарко\t' .. ini.global.key:gsub("VK_", '')
      dialogLine[#dialogLine + 1] = ' Сокращенная команда\t' .. ini.global.cmd
      dialogTextToList[#dialogLine] = "{FFFFFF}Введите сокращенную команду для принятия наркотиков!"
      dialogLine[#dialogLine + 1] = ' Текст когда таймер стоит\t' .. ini.lines.one
      dialogTextToList[#dialogLine] = "{FFFFFF}Введите текст таймера когда он отключен.\n\tМожно использовать замены и цвета HEX\n\t  {036d80}!n{FFFFFF} - переход на новую строку\n\t  {036d80}!a{FFFFFF} - заменится на остаток наркотиков\n\t  {036d80}!m{FFFFFF} - заменится на остаток материалов"
      dialogLine[#dialogLine + 1] = ' Текст когда идёт таймер\t' .. ini.lines.two
      dialogTextToList[#dialogLine] = "{FFFFFF}Введите текст таймера когда он работает.\n\tМожно использовать замены и цвета HEX\n\t  {036d80}!n{FFFFFF} - переход на новую строку\n\t  {036d80}!a{FFFFFF} - заменится на остаток наркотиков\n\t  {036d80}!s{FFFFFF} - заменится на остаток секунд\n\t  {036d80}!m{FFFFFF} - заменится на остаток материалов"
      dialogLine[#dialogLine + 1] = ' Шрифт\t' .. ini.render.font
      dialogTextToList[#dialogLine] = "{FFFFFF}Введите название шрифта"
      dialogLine[#dialogLine + 1] = ' Размер\t' .. ini.render.size
      dialogTextToList[#dialogLine] = "{FFFFFF}Введите размер шрифта"
      dialogLine[#dialogLine + 1] = ' Стиль\t' .. ini.render.flag
      dialogTextToList[#dialogLine] = "{FFFFFF}Устанавливайте стиль путем сложения.\n\nТекст без особенностей = 0\nЖирный текст = 1\nНаклонность(Курсив) = 2\nОбводка текста = 4\nТень текста = 8\nПодчеркнутый текст = 16\nЗачеркнутый текст = 32\n\nСтандарт: 13"
      dialogLine[#dialogLine + 1] = ' Выравнивание\t' .. (ini.render.align == 1 and "От левого края" or (ini.render.align == 2 and "По середине" or (ini.render.align == 3 and " От правого края" or '')))
      dialogLine[#dialogLine + 1] = ' Отступ новой строки\t' .. ini.render.height
      dialogTextToList[#dialogLine] = "{FFFFFF}Введите число от 2 до 10."
      dialogLine[#dialogLine + 1] = '{59fc30}Контакты автора\t'
      local text = ""
      for k, v in pairs(dialogLine) do
        text = text .. v .. "\n"
      end
      sampShowDialog(5501, 'Drugs-Mats: Настройки', text, "Выбрать", "Закрыть", 4)
    end
    if int == 2 then
      d[7] = true
      sampShowDialog(5501, "Drugs-Mats: Изменение настроек", dtext, "Выбрать", "Назад", 1)
    end
    if int == 3 then
      sampShowDialog(5501, "Drugs-Mats: Контакты автора", "{FFFFFF}Выбери что скопировать\t\nНик на Samp-Rp\tSerhiy_Rubin\nСтраничка {4c75a3}VK{FFFFFF}\tvk.com/id353828351\nГруппа {4c75a3}VK{FFFFFF} с модами\tvk.com/club161589495\n{10bef2}Skype{FFFFFF}\tserhiyrubin\n{7289da}Discord{FFFFFF}\tSerhiy_Rubin#3391", "Копировать", "Назад", 5)
    end
  end

  local rubin_drugs_mats_doDialog = function()
    --if not sampIsDialogActive() then
    --  return
    --end
    if sampGetDialogCaption() == 'Drugs-Mats: Настройки' then
      local result, button, list, input = sampHasDialogRespond(5501)
      if result and button == 1 then
        if dialogLine ~= nil and dialogLine[list + 1] ~= nil then
          local str = dialogLine[list + 1]
          if str:find('Скрипт') then
            ini[inikeys].run = not ini[inikeys].run
            inicfg.save(ini, "edith-drugs-mats")
            rubin_drugs_mats_ShowDialog(1)
          end
          if str:find('Сменить позицию') then
            table.insert(tempThreads, lua_thread.create(function()
              wait(200)
              pos = true
            end))
          end
          if str:find('Проверка инвентаря') then
            ini[inikeys].inventory = not ini[inikeys].inventory
            inicfg.save(ini, "edith-drugs-mats")
            rubin_drugs_mats_ShowDialog(1)
          end
          if str:find('Серверная команда принять нарко') then
            rubin_drugs_mats_ShowDialog(2, dialogTextToList[list + 1], ini[inikeys].server_cmd, true, inikeys, 'server_cmd')
          end
          if str:find('Базовое кд') then
            rubin_drugs_mats_ShowDialog(2, dialogTextToList[list + 1], ini[inikeys].seconds, false, inikeys, 'seconds')
          end
          if str:find('Максимальное HP') then
            rubin_drugs_mats_ShowDialog(2, dialogTextToList[list + 1], ini[inikeys].hp, false, inikeys, 'hp')
          end
          if str:find('Максимум грамм можно использовать') then
            rubin_drugs_mats_ShowDialog(2, dialogTextToList[list + 1], ini[inikeys].max_use_gram, false, inikeys, 'max_use_gram')
          end
          if str:find('HP дает 1 грамм наркотиков') then
            rubin_drugs_mats_ShowDialog(2, dialogTextToList[list + 1], ini[inikeys].hp_one_gram, false, inikeys, 'hp_one_gram')
          end
          if str:find('Сокращенная команда') then
            rubin_drugs_mats_ShowDialog(2, dialogTextToList[list + 1], ini.global.cmd, true, 'global', 'cmd')
          end
          if str:find('Текст когда таймер стоит') then
            rubin_drugs_mats_ShowDialog(2, dialogTextToList[list + 1], ini.lines.one, true, 'lines', 'one')
          end
          if str:find('Текст когда идёт таймер') then
            rubin_drugs_mats_ShowDialog(2, dialogTextToList[list + 1], ini.lines.two, true, 'lines', 'two')
          end
          if str:find('Шрифт') then
            rubin_drugs_mats_ShowDialog(2, dialogTextToList[list + 1], ini.render.font, true, 'render', 'font')
          end
          if str:find('Размер') then
            rubin_drugs_mats_ShowDialog(2, dialogTextToList[list + 1], ini.render.size, true, 'render', 'size')
          end
          if str:find('Стиль') then
            rubin_drugs_mats_ShowDialog(2, dialogTextToList[list + 1], ini.render.flag, true, 'render', 'flag')
          end
          if str:find('Выравнивание') then
            ini.render.align = (ini.render.align == 1 and 2 or (ini.render.align == 2 and 3 or (ini.render.align == 3 and 1 or 2)))
            inicfg.save(ini, "edith-drugs-mats")
            rubin_drugs_mats_ShowDialog(1)
          end
          if str:find('Отступ новой строки') then
            rubin_drugs_mats_ShowDialog(2, dialogTextToList[list + 1], ini.render.height, false, 'render', 'height')
          end
          if str:find('Контакты автора') then
            rubin_drugs_mats_ShowDialog(3)
          end
          if str:find('Кнопка для использвания нарко') then
            table.insert(tempThreads, lua_thread.create(function()
              wait(150)
              local keys = ""
              repeat
                wait(0)
                for k, v in pairs(vkeys) do
                  if not sampIsDialogActive() then
                    sampShowDialog(5501, "Смена клавиши", "{FFFFFF}Нажмите на любую клавишу\nОна будет использоваться для использования наркотика", "Выбрать", "Закрыть", 0)
                  end
                  if wasKeyPressed(v) and k ~= "VK_ESCAPE" and k ~= "VK_RETURN" and k ~= "VK_SPACE" then
                    keys = k
                  end
                end
              until keys ~= ""
              ini.global.key = keys
              inicfg.save(ini, "edith-drugs-mats")
              rubin_drugs_mats_ShowDialog(1)
            end))
          end
        end
      end
    end
    if sampGetDialogCaption() == "Drugs-Mats: Изменение настроек" then
      if d[7] then
        d[7] = false
        sampSetCurrentDialogEditboxText(ini[d[5]][d[6]])
      end
      local result, button, list, input = sampHasDialogRespond(0)
      if result then
        if button == 1 then
          local gou = (d[4] and (#input > 0 and true or false) or (input:find("^%d+$") and true or false))
          if gou then
            d[3] = (d[4] and tostring(input) or tonumber(input))
            ini[d[5]][d[6]] = d[3]
            inicfg.save(ini, "edith-drugs-mats")
            if d[5]:find('render') then
              renderReleaseFont(font_drugs)
              font_drugs = renderCreateFont(ini.render.font, ini.render.size, ini.render.flag)
            end
            if d[5]:find('lines') then
              rubin_drugs_mats_text_to_table()
            end
            rubin_drugs_mats_ShowDialog(1)
          else
            rubin_drugs_mats_ShowDialog(d[1], d[2], d[3], d[4], d[5], d[6])
          end
        else
          rubin_drugs_mats_ShowDialog(1)
        end
      end
    end
    if sampGetDialogCaption() == "Drugs-Mats: Контакты автора" then
      local result, button, list, input = sampHasDialogRespond(0)
      if result then
        if button == 1 then
          if list == 0 then
            setClipboardText("Serhiy_Rubin")
          end
          if list == 1 then
            setClipboardText("https://vk.com/id353828351")
          end
          if list == 2 then
            setClipboardText("https://vk.com/club161589495")
          end
          if list == 3 then
            setClipboardText("serhiyrubin")
          end
          if list == 4 then
            setClipboardText("Serhiy_Rubin#3391")
          end
          rubin_drugs_mats_ShowDialog(3)
        else
          rubin_drugs_mats_ShowDialog(1)
        end
      end
    end
  end

  local mainThread = function()
    if not isSampLoaded() or not isSampfuncsLoaded() then
      return
    end
    while not isSampAvailable() do
      wait(100)
    end
    wait(300)
    if settings.drugsmats.enable then
      for id = 1, 1000 do
        local s = script.get(id)
        if s then
          if s.name == "Drugs-Mats" and s.dead == false then
            s:unload()
            if isSampAvailable() and isSampfuncsLoaded() then

              if settings.welcome.show then
                sampAddChatMessage("{348cb2}[EDITH]: {ff0000}Обнаружен загруженный Drugs-Mats rubin'a. {7ef3fa}У вас включен его улучшенный аналог в EDITH, убиваю оригинал...", 0xff0000)
              end
            end
          end
        end
      end
    end

    inicfg.save(ini, "edith-drugs-mats")
    wait(200)
    table.insert(tempThreads, lua_thread.create(rubin_drugs_mats_GetMats))
    wait(200)
    font_drugs = renderCreateFont(ini.render.font, ini.render.size, ini.render.flag)
    rubin_drugs_mats_text_to_table()
    while true do
      wait(0)
      if settings.drugsmats.enable then
        rubin_drugs_mats_doDialog()
        if sampIsChatInputActive() and sampGetChatInputText() == "/q" and wasKeyPressed(13) then
          anti_hang = true
        end
        if isCharDead(playerPed) then
          drugs_timer = 0
        end
        if ini[inikeys].run and not sampIsScoreboardOpen() and sampIsChatVisible() and not isKeyDown(116) and not isKeyDown(121) and anti_hang == nil then
          second_timer = os.difftime(os.time(), drugs_timer)
          render_table = ((second_timer <= ini[inikeys].seconds * bonus_drugs and second_timer > 0) and renderText[4] or renderText[3])
          X = 0
          Y, Height = ini.render.y, (renderGetFontDrawHeight(font_drugs) - (renderGetFontDrawHeight(font_drugs) / ini.render.height))
          for i = 1, #render_table do
            if render_table[i] ~= nil then
              string_gsub = render_table[i]:gsub("!a", ini[inikeys].drugs)
              string_gsub = string_gsub:gsub("!s", tostring(ini[inikeys].seconds * bonus_drugs - second_timer))
              string_gsub = string_gsub:gsub("!m", tostring(ini[inikeys].mats))
              if ini.render.align == 1 then
                X = ini.render.x
              end
              if ini.render.align == 2 then
                X = ini.render.x - (renderGetFontDrawTextLength(font_drugs, string_gsub) / 2)
              end
              if ini.render.align == 3 then
                X = ini.render.x - renderGetFontDrawTextLength(font_drugs, string_gsub)
              end
              renderFontDrawText(font_drugs, string_gsub, X, Y, 0xFFFFFFFF)
              Y = Y + Height
            end
          end

          if isKeyJustPressed(vkeys[ini.global.key]) and not sampIsDialogActive() and not sampIsChatInputActive() and not sampIsCursorActive() then
            gramm = math.ceil(((ini[inikeys].hp + 1) - getCharHealth(playerPed)) / ini[inikeys].hp_one_gram)
            if gramm > tonumber(ini[inikeys].drugs) then
              gramm = tonumber(ini[inikeys].drugs)
            end
            if gramm > ini[inikeys].max_use_gram then
              gramm = ini[inikeys].max_use_gram
            end
            --if second_timer <= ini[inikeys].seconds * bonus_drugs and second_timer > 0 then
            --  gramm = 1
            --end
            sampSendChat(string.format('/%s %d', ini[inikeys].server_cmd, gramm))
          end

          if pos then
            sampSetCursorMode(3)
            curX, curY = getCursorPos()
            ini.render.x = curX
            ini.render.y = curY
            if isKeyJustPressed(1) then
              sampSetCursorMode(0)
              pos = false
              inicfg.save(ini, "edith-drugs-mats")
            end
          end
        end
      end
    end
  end

  local getMenu = function()
    return {
      title = "{7ef3fa}* " .. (settings.drugsmats.enable and "{00ff66}" or "{ff0000}") .. "DRUGS MATS [улучшен]",
      submenu = {
        {
          title = "Информация о модуле",
          onclick = function()
            sampShowDialog(
                    0,
                    "{7ef3fa}/edith v." .. thisScript().version .. ' - информация о модуле {00ff66}"DRUGS MATS"',
                    "{00ff66}DRUGS MATS{ffffff}\n{ffffff}Скрипт рубина для рендера остатка наркотиков и материалов на экране.\nЕсть хоткей ({00ccff}" ..
                            tostring(key.id_to_name(vkeys[ini.global.key])) ..
                            "{ffffff}) для быстрого юза нарко.\nЕсли EDITH обнаружит оригинальный скрипт, работа оригинала будет завершена.\n\nОтличия от оригинала:\n1. Сброс кд при смерти\n2. Автодетектор кд при бонусах.\n3. Учтен момент, когда нарко нужно больше, чем есть.",
                    "Окей"
            )
          end
        },
        {
          title = " "
        },
        {
          title = "Включить: " .. tostring(settings.drugsmats.enable),
          onclick = function()
            settings.drugsmats.enable = not settings.drugsmats.enable
            inicfg.save(settings, "edith")
          end
        },
        {
          title = "Настройка",
          onclick = function()
            sampProcessChatInput("/usedrugs menu")
          end
        }
      }
    }
  end

  local description = function()
    return "{7ef3fa}* " .. (settings.drugsmats.enable and "{00ff66}" or "{ff0000}") .. "DRUGS MATS - {ffffff}Таймер наркотиков на {00ccff}" ..
            tostring(key.id_to_name(vkeys[ini.global.key])) ..
            "{ffffff}, умеет сам обновлять кд при бонусах."
  end

  local enableAll = function()
    settings.drugsmats.enable = true
  end

  local disableAll = function()
    settings.drugsmats.enable = false
  end

  local defaults = {
    enable = true
  }

  local loadIni = function()
    inikeys = string.format('%s %s-%s', my_name, ip123:gsub('%.', '-'), port)

    ini = inicfg.load(
            {
              render = {
                font = 'Segoe UI',
                size = 10,
                flag = 13,
                align = 2,
                x = posX,
                y = posY,
                height = 4
              },
              global = {
                cmd = 'us',
                key = 'VK_X'
              },
              [inikeys] = {
                hp = 160,
                hp_one_gram = 10,
                max_use_gram = 15,
                seconds = 60,
                run = true,
                drugs = 0,
                mats = 0,
                server_cmd = 'usedrugs',
                inventory = true
              },
              lines = {
                one = '{1a9614}drugs !a',
                two = '{1a9614}drugs !a!n{e81526}cooldown !s'
              }
            },
            "edith-drugs-mats"
    )
  end

  local checkBoostInfo = function()
    wait(200)
    if settings.rcapture.active then
      wait(500)
    end
    antiFlood()
    check_bonus = 2
    sampSendChat('/boostinfo')
  end

  local onServerMessage = function(color, text)
    if check_bonus == 2 and color == -1 and text:find("Бонусы отключены") then
      check_bonus = 0
      return false
    end
    if check_bonus == 2 and color == -1 and text:find("Действует до") then
      return false
    end

    if settings.drugsmats.enable then
      local message = text
      if (message == " (( Здоровье не пополняется чаще, чем раз в минуту ))" or message == ' (( Здоровье можно пополнить не чаще, чем раз в минуту ))') then
        not_drugs_timer = true
      end
      if string.find(message, my_name) then
        if string.find(message, "употребил%(а%) наркотик") then
          if not not_drugs_timer then
            drugs_timer = os.time()
          else
            not_drugs_timer = false
          end
        end
        --if string.find(message, "оружие из материалов") then
        --  table.insert(threads, lua_thread.create(rubin_drugs_mats_GetMats)
        --end
      end
      if message:find('выбросил') and (message:find('аркотики') or message:find('атериалы')) and string.find(message, my_name) then
        table.insert(tempThreads, lua_thread.create(rubin_drugs_mats_GetMats))
      end
      if message:find('Вы взяли несколько комплектов') then
        table.insert(tempThreads, lua_thread.create(rubin_drugs_mats_GetMats))
      end
      if message:find('Вы ограбили дом! Наворованный металл можно сдать около порта.') then
        table.insert(tempThreads, lua_thread.create(rubin_drugs_mats_GetMats))
      end
      if message:find('У вас (%d+)/500 материалов с собой') then
        ini[inikeys].mats = message:match('У вас (%d+)/500 материалов с собой')
        inicfg.save(ini, "edith-drugs-mats")
      end
      if string.find(message, " %(%( Остаток: (%d+) грамм %)%)") then
        if not not_drugs_timer then
          drugs_timer = os.time()
        else
          not_drugs_timer = false
        end
        ini[inikeys].drugs = string.match(message, " %(%( Остаток: (%d+) грамм %)%)")
        inicfg.save(ini, "edith-drugs-mats")
      end
      if string.find(message, '%(%( Остаток: (%d+) материалов %)%)') then
        ini[inikeys].mats = message:match('%(%( Остаток: (%d+) материалов %)%)')
        inicfg.save(ini, "edith-drugs-mats")
      end
      if message:find('Не флуди!') and check_inventory == 2 then
        table.insert(tempThreads, lua_thread.create(rubin_drugs_mats_GetMats))
      end
      if message:find('Вы купили %d+ грамм за %d+ вирт %(У вас есть (%d+) грамм%)') then
        ini[inikeys].drugs = message:match('Вы купили %d+ грамм за %d+ вирт %(У вас есть (%d+) грамм%)')
        inicfg.save(ini, "edith-drugs-mats")
      end
      if message:find(' %d+ грамм наркотических лекарств') then
        table.insert(tempThreads, lua_thread.create(rubin_drugs_mats_GetMats))
      end
      if message:find(' Вы купили (%d+) грамм за %d+ вирт, у .+') then
        local s1 = message:match(' Вы купили (%d+) грамм за %d+ вирт, у .+')
        ini[inikeys].drugs = tonumber(s1) + ini[inikeys].drugs
        inicfg.save(ini, "edith-drugs-mats")
      end
    end
  end

  local onSendChat = function(message)
    sleep = os.clock() * 1000
  end

  local onSendCommand = function(cmd)
    if settings.drugsmats.enable then
      command, params = string.match(cmd:lower(), "^%/([^ ]*)(.*)")
      if command == ini.global.cmd:lower() or string.find(command, ini[inikeys].server_cmd) then
        if string.find(params, "menu") then
          rubin_drugs_mats_ShowDialog(1)
          return false
        end
        if #params == 0 then
          gramm = math.ceil(((ini[inikeys].hp + 1) - getCharHealth(playerPed)) / ini[inikeys].hp_one_gram)
          if gramm > ini[inikeys].max_use_gram then
            gramm = ini[inikeys].max_use_gram
          end
          second_timer = os.difftime(os.time(), drugs_timer)
          --if second_timer <= ini[inikeys].seconds * bonus_drugs and second_timer > 0 then
          --  gramm = 1
          --end

          return { string.format('/%s %d', ini[inikeys].server_cmd, gramm) }
        end
        if command == ini.global.cmd:lower() then
          cmd = cmd:lower():gsub(ini.global.cmd:lower(), ini[inikeys].server_cmd)
          return { cmd }
        end
      end
    end

    sleep = os.clock() * 1000
  end

  local onShowDialog = function(dialog, style, title, button1, button2, text)
    if dialog == 22 and title == "Бонусы" then
      for string in string.gmatch(text, '[^\n]+') do
        if string:find('Таймер на Нарко	(.+)') then
          bonus_drugs = tonumber(string:match('Таймер на Нарко	(.+)'))
        end
      end
      if check_bonus == 2 then
        check_bonus = 0
        return false
      end
    end

    if settings.drugsmats.enable then
      if title:find('Информация') or title:find('Карманы') then
        local nark, mats = false, false
        for string in string.gmatch(text, '[^\n]+') do
          if string:find('Наркотики\t(%d+)') then
            ini[inikeys].drugs = string:match('Наркотики\t(%d+)')
            nark = true
          end
          if string:find('Материалы\t(%d+)') then
            ini[inikeys].mats = string:match('Материалы\t(%d+)')
            mats = true
          end
          if not nark then
            ini[inikeys].drugs = 0
          end
          if not mats then
            ini[inikeys].mats = 0
          end
          inicfg.save(ini, "edith-drugs-mats")
        end
        if check_inventory == 2 then
          check_inventory = 0
          sampSendDialogResponse(dialog, 0, 0, "")
          return false
        end
      end
    end
  end

  return {
    main = mainThread,
    checkboost = checkBoostInfo,
    ini = loadIni,
    getMenu = getMenu,
    desc = description,
    enable = enableAll,
    disable = disableAll,
    defaults = defaults,
    onShowDialog = onShowDialog,
    onServerMessage = onServerMessage,
    onSendChat = onSendChat,
    onSendCommand = onSendCommand
  }
end
--------------------------------------------------------------------------------
------------------------------------IZNANKA-------------------------------------
--------------------------------------------------------------------------------
function iznankaModule()
  local iznanka_active = false
  local break_timer = os.clock()

  local sleep = 0

  local antiFlood = function()
    repeat
      wait(100)
      local res, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
      local ms = math.ceil(os.clock() * 1000 - sleep)
    until ms > 1200 and sampGetPlayerScore(id) >= 1 and not sampIsDialogActive() and not sampIsChatInputActive()
  end

  local mainThread = function()
    while true do
      wait(100)
      if settings.iznanka.enable then
        if isKeyJustPressed(settings.iznanka.key) then
          if not sampIsChatInputActive() and not sampIsDialogActive() and not isSampfuncsConsoleActive() and not isCharInAnyCar(playerPed) then
            iznanka_active = not iznanka_active
            if iznanka_active then
              table.insert(tempThreads, lua_thread.create(
                      function()
                        local result1, id1 = sampGetPlayerIdByCharHandle(playerPed)
                        if result1 then
                          sampSendChat("/anim 3")

                          break_timer = os.clock()
                          while sampGetPlayerSpecialAction(id1) ~= 7 do
                            wait(0)
                            if os.clock() - break_timer > 1 then
                              break
                            end
                          end
                          wait(100)

                          if settings.iznanka.usedrugs then
                            if settings.rcapture.active then
                              wait(200)
                            end
                            table.insert(tempThreads, lua_thread.create(
                                    function()
                                      antiFlood()
                                      sampSendChat("/usedrugs")
                                    end
                            ))
                          end

                          setVirtualKeyDown(settings.iznanka.keyS, true)
                          setVirtualKeyDown(83, true)
                          while iznanka_active do
                            setVirtualKeyDown(65, true)
                            wait(400)
                            setVirtualKeyDown(65, false)
                            wait(65)
                            setVirtualKeyDown(68, true)
                            wait(400)
                            setVirtualKeyDown(68, false)
                            wait(65)
                          end
                        end
                      end
              ))
            else
              setVirtualKeyDown(65, false)
              setVirtualKeyDown(68, false)
              setVirtualKeyDown(83, false)
              setVirtualKeyDown(settings.iznanka.keyS, false)
              sampSetSpecialAction(0)
            end
          end
        end
        if iznanka_active then
          if isKeyJustPressed(70) or isCharDead(playerPed) then
            iznanka_active = false
            setVirtualKeyDown(65, false)
            setVirtualKeyDown(68, false)
            setVirtualKeyDown(83, false)
            setVirtualKeyDown(32, false)
            sampSetSpecialAction(0)
          end
        end
      end
    end
  end

  local changeiznankakey = function(mode)
    sampShowDialog(
            989,
            "Изменение горячей клавиши активации iznanka",
            'Нажмите "Окей", после чего нажмите нужную клавишу.\nНастройки будут изменены.',
            "Окей",
            "Закрыть"
    )
    while sampIsDialogActive(989) do
      wait(100)
    end
    local resultMain, buttonMain, typ = sampHasDialogRespond(989)
    if buttonMain == 1 then
      while ke1y == nil do
        wait(0)
        for i = 1, 200 do
          if isKeyDown(i) then
            if mode == 0 then
              settings.iznanka.key = i
            else
              settings.iznanka.keyS = i
            end
            sampAddChatMessage("Установлена новая горячая клавиша - " .. key.id_to_name(i), -1)
            addOneOffSound(0.0, 0.0, 0.0, 1052)
            inicfg.save(settings, "edith")
            ke1y = 1
            break
          end
        end
      end
      ke1y = nil
    end
  end

  local getMenu = function()
    return {
      title = "{7ef3fa}* " .. (settings.iznanka.enable and "{00ff66}" or "{ff0000}") .. "IZNANKA",
      submenu = {
        {
          title = "Информация о модуле",
          onclick = function()
            sampShowDialog(
                    0,
                    "{7ef3fa}/edith v." .. thisScript().version .. ' - информация о модуле {00ff66}"IZNANKA"',
                    "{00ff66}IZANKA{ffffff}\nПозволяет по нажатию хоткея войти в параллельное измерение.\nМожно использовать, чтобы пополнить хп наркотиками и продолжить бой.\nДля этого нужно подойти к текстуре и активировать скрипт.\n\nПримечание:\n* Автор - рома попрыгун.\n* Активация - {00ccff}" .. tostring(key.id_to_name(settings.iznanka.key)) .. "{ffffff}, можно изменить.\n* Деактивация - {00ccff}F{ffffff}.\n* Реакция администрации на это неизвестна, могут счесть читом.",
                    "Окей"
            )
          end
        },
        {
          title = "Включить: " .. tostring(settings.iznanka.enable),
          onclick = function()
            settings.iznanka.enable = not settings.iznanka.enable
            inicfg.save(settings, "edith")
          end
        },
        {
          title = " "
        },
        {
          title = "Включить авто /usedrugs: " .. tostring(settings.iznanka.usedrugs),
          onclick = function()
            settings.iznanka.usedrugs = not settings.iznanka.usedrugs
            inicfg.save(settings, "edith")
          end
        },
        {
          title = "Изменить клавишу, сейчас: " .. tostring(tostring(key.id_to_name(settings.iznanka.key))),
          onclick = function()
            table.insert(tempThreads, lua_thread.create(changeiznankakey, 0))
          end
        },
        {
          title = "Изменить клавишу бега, сейчас: " .. tostring(tostring(key.id_to_name(settings.iznanka.keyS))),
          onclick = function()
            table.insert(tempThreads, lua_thread.create(changeiznankakey, 1))
          end
        },
      }
    }
  end

  local description = function()
    return "{7ef3fa}* " .. (settings.iznanka.enable and "{00ff66}" or "{ff0000}") .. "IZNANKA - {ffffff}/usedrugs в текстурах через анимку танца, активация: {00ccff}" ..
            tostring(key.id_to_name(settings.iznanka.key)) ..
            "{ffffff}."
  end

  local enableAll = function()
    settings.iznanka.enable = true
  end

  local disableAll = function()
    settings.iznanka.enable = false
  end

  local defaults = {
    enable = false,
    usedrugs = true,
    key = 114,
    keyS = 32,
  }

  local onSendChat = function(message)
    sleep = os.clock() * 1000
  end

  local onSendCommand = function(cmd)
    sleep = os.clock() * 1000
  end

  return {
    main = mainThread,
    getMenu = getMenu,
    desc = description,
    enable = enableAll,
    disable = disableAll,
    defaults = defaults,
    onSendChat = onSendChat,
    onSendCommand = onSendCommand
  }
end
--------------------------------------------------------------------------------
-------------------------------------HEALME-------------------------------------
--------------------------------------------------------------------------------
function healmeModule()
  local heal = false

  local asodkas, licenseid = sampGetPlayerIdByCharHandle(PLAYER_PED)
  local licensenick = sampGetPlayerNickname(licenseid)

  local health = 0
  local result, id = 0, 0

  local sleep = 0

  local antiFlood = function()
    repeat
      wait(100)
      local res, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
      local ms = math.ceil(os.clock() * 1000 - sleep)
    until ms > 1200 and sampGetPlayerScore(id) >= 1 and not sampIsDialogActive() and not sampIsChatInputActive()
  end

  local mainThread = function()
    while true do
      wait(100)
      if settings.healme.enable then
        repeat
          wait(100)
          if heal then
            result, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
            health = sampGetPlayerHealth(id)
            if health < 100 then
              if settings.rcapture.active then
                wait(500)
              end
              antiFlood()
              result, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
              health = sampGetPlayerHealth(id)
              if health < 100 then
                sampSendChat("/healme")
              end
            else
              wait(2000)
              heal = false
            end
          end
        until not heal
      end
    end
  end

  local getMenu = function()
    return {
      title = "{7ef3fa}* " .. (settings.healme.enable and "{00ff66}" or "{ff0000}") .. "HEALME",
      submenu = {
        {
          title = "Информация о модуле",
          onclick = function()
            sampShowDialog(
                    0,
                    "{7ef3fa}/edith v." .. thisScript().version .. ' - информация о модуле {00ff66}"HEALME"',
                    "{00ff66}HEALME{ffffff}\nПытается восстановить хп до 100 в интерьерах с анти-флудом.",
                    "Окей"
            )
          end
        },
        {
          title = "Включить: " .. tostring(settings.healme.enable),
          onclick = function()
            settings.healme.enable = not settings.healme.enable
            inicfg.save(settings, "edith")
          end
        }
      }
    }
  end

  local description = function()
    return "{7ef3fa}* " .. (settings.healme.enable and "{00ff66}" or "{ff0000}") .. "HEALME - {ffffff}Автохил аптечками в интерьерах, создан для экономии наркотиков."
  end

  local enableAll = function()
    settings.healme.enable = true
  end

  local disableAll = function()
    settings.healme.enable = false
  end

  local defaults = {
    enable = true
  }

  local onSetInterior = function(id)
    if id ~= 0 then
      heal = true
    end
  end

  local onServerMessage = function(color, text)
    if settings.healme.enable then
      if heal and (text == " В этом месте нет аптечки" or text == " Сейчас не получится. Вы используете намного больше аптечек, чем остальные" or text == " Вы не нуждаетесь в лечении" or text == " Вы должны быть на своей базе или дома" or text == " Аптечку можно использовать не более 10 раз в час") then
        heal = false
        return false
      end

      if heal and (text == " " .. licensenick .. " использовал(а) аптечку" or text == " Вы были вылечены на 25 хп") then
        return false
      end
    end
  end

  local onSendChat = function(message)
    sleep = os.clock() * 1000
  end

  local onSendCommand = function(cmd)
    sleep = os.clock() * 1000
  end

  return {
    main = mainThread,
    getMenu = getMenu,
    desc = description,
    enable = enableAll,
    disable = disableAll,
    defaults = defaults,
    onSetInterior = onSetInterior,
    onServerMessage = onServerMessage,
    onSendChat = onSendChat,
    onSendCommand = onSendCommand
  }
end
--------------------------------------------------------------------------------
----------------------------------DOUBLE_JUMP-----------------------------------
--------------------------------------------------------------------------------
function doubleJumpModule()
  local mainThread = function()
    while true do
      wait(100)
      if settings.doublejump.enable and isKeyJustPressed(settings.doublejump.key) then
        if not sampIsChatInputActive() and not sampIsDialogActive() then
          sampSendChat("/anim 31")
          for i = 0, 15 do
            setVirtualKeyDown(settings.doublejump.keyJ, true)
            wait(10)
            setVirtualKeyDown(settings.doublejump.keyJ, false)
            wait(30)
          end
        end
      end
    end
  end

  local changedoublejumpkey = function(mode)
    sampShowDialog(
            989,
            "Изменение горячей клавиши активации doublejump или клавиши прыжка",
            'Нажмите "Окей", после чего нажмите нужную клавишу.\nНастройки будут изменены.',
            "Окей",
            "Закрыть"
    )
    while sampIsDialogActive(989) do
      wait(100)
    end
    local resultMain, buttonMain, typ = sampHasDialogRespond(989)
    if buttonMain == 1 then
      while ke1y == nil do
        wait(0)
        for i = 1, 200 do
          if isKeyDown(i) then
            if mode == 1 then
              settings.doublejump.key = i
            else
              settings.doublejump.keyJ = i
            end
            sampAddChatMessage("Установлена новая горячая клавиша - " .. key.id_to_name(i), -1)
            addOneOffSound(0.0, 0.0, 0.0, 1052)
            inicfg.save(settings, "edith")
            ke1y = 1
            break
          end
        end
      end
      ke1y = nil
    end
  end

  local getMenu = function()
    return {
      title = "{7ef3fa}* " .. (settings.doublejump.enable and "{00ff66}" or "{ff0000}") .. "DOUBLE_JUMP {808080}[STABLE]",
      submenu = {
        {
          title = "Информация о модуле",
          onclick = function()
            sampShowDialog(
                    0,
                    "{7ef3fa}/edith v." .. thisScript().version .. ' - информация о модуле {00ff66}"DOUBLE_JUMP"',
                    "{00ff66}DOUBLE_JUMP{ffffff}\nПо нажатию {00ccff}" .. tostring(key.id_to_name(settings.doublejump.key)) .. "{ffffff} делает дабл жамп.\nЭто не чит, а багоюз с анимкой, но возможны санкции со стороны администрации.\nПо умолчанию выключен.\n\nПримечание:\n* Автор - рома попрыгун.",
                    "Окей"
            )
          end
        },
        {
          title = "Включить: " .. tostring(settings.doublejump.enable),
          onclick = function()
            settings.doublejump.enable = not settings.doublejump.enable
            inicfg.save(settings, "edith")
          end
        },
        {
          title = "Изменить клавишу, сейчас: " .. tostring(tostring(key.id_to_name(settings.doublejump.key))),
          onclick = function()
            table.insert(tempThreads, lua_thread.create(changedoublejumpkey, 1))
          end
        },
        {
          title = "Изменить клавишу прыжка, сейчас: " .. tostring(tostring(key.id_to_name(settings.doublejump.keyJ))),
          onclick = function()
            table.insert(tempThreads, lua_thread.create(changedoublejumpkey, 0))
          end
        }
      }
    }
  end

  local description = function()
    return "{7ef3fa}* " .. (settings.doublejump.enable and "{00ff66}" or "{ff0000}") .. "DOUBLE_JUMP - {ffffff}Дабл джамп (багоюз) по нажатию клавиши {00ccff}" ..
            tostring(key.id_to_name(settings.doublejump.key)) ..
            "{ffffff}."
  end

  local enableAll = function()
    settings.doublejump.enable = true
  end

  local disableAll = function()
    settings.doublejump.enable = false
  end

  local defaults = {
    enable = true,
    key = 66,
    keyJ = 16,
    delay = 0,
  }

  return {
    main = mainThread,
    getMenu = getMenu,
    desc = description,
    enable = enableAll,
    disable = disableAll,
    defaults = defaults
  }
end
--------------------------------------------------------------------------------
-----------------------------------PARASHUTE------------------------------------
--------------------------------------------------------------------------------
function parashuteModule()
  local sleep = 0

  local antiFlood = function()
    repeat
      wait(100)
      local res, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
      local ms = math.ceil(os.clock() * 1000 - sleep)
    until ms > 600 and sampGetPlayerScore(id) >= 1 and not sampIsDialogActive() and not sampIsChatInputActive()
  end

  local mainThread = function()
    while true do
      wait(100)
      if settings.parashute.enable then
        if isKeyJustPressed(settings.parashute.key) then
          if not sampIsChatInputActive() and not isSampfuncsConsoleActive() and not sampIsDialogActive() and not isCharInAnyCar(playerPed) then
            local result1, id1 = sampGetPlayerIdByCharHandle(playerPed)
            if result1 then
              if getCurrentCharWeapon(playerPed) == 464 then
                local break_timer = os.clock()
                local charSpeed = math.ceil(getCharSpeed(PLAYER_PED))
                while getCharHeightAboveGround(playerPed) > (67.5 + charSpeed / 15) do
                  charSpeed = math.ceil(getCharSpeed(PLAYER_PED))
                  --printStyledString(tostring(charSpeed).."m/s  "..tostring(math.ceil(getCharHeightAboveGround(playerPed))).."m", 500, 7)
                  wait(0)
                  if os.clock() - break_timer > 300 then
                    break
                  end
                end
                --wait(80)
                setVirtualKeyDown(1, true)
                wait(1)
                setVirtualKeyDown(1, false)
              else
                antiFlood()
                sampSendChat("/piss")
                local break_timer = os.clock()
                while sampGetPlayerSpecialAction(id1) ~= 68 do
                  wait(0)
                  if os.clock() - break_timer > 1 then
                    break
                  end
                end

                local break_timer = os.clock()
                local charSpeed = math.ceil(getCharSpeed(PLAYER_PED))
                while getCharHeightAboveGround(playerPed) > (3.2 + charSpeed / 15) do
                  charSpeed = math.ceil(getCharSpeed(PLAYER_PED))
                  --printStyledString(tostring(charSpeed).."m/s  "..tostring(math.ceil(getCharHeightAboveGround(playerPed))).."m", 500, 7)
                  wait(0)
                  if os.clock() - break_timer > 300 then
                    break
                  end
                end
                --wait(80)
                setVirtualKeyDown(70, true)
                wait(1)
                setVirtualKeyDown(70, false)
              end
            end
          end
        end
      end
    end
  end

  local changeparashutekey = function()
    sampShowDialog(
            989,
            "Изменение горячей клавиши активации parashute",
            'Нажмите "Окей", после чего нажмите нужную клавишу.\nНастройки будут изменены.',
            "Окей",
            "Закрыть"
    )
    while sampIsDialogActive(989) do
      wait(100)
    end
    local resultMain, buttonMain, typ = sampHasDialogRespond(989)
    if buttonMain == 1 then
      while ke1y == nil do
        wait(0)
        for i = 1, 200 do
          if isKeyDown(i) then
            settings.parashute.key = i
            sampAddChatMessage("Установлена новая горячая клавиша - " .. key.id_to_name(i), -1)
            addOneOffSound(0.0, 0.0, 0.0, 1052)
            inicfg.save(settings, "edith")
            ke1y = 1
            break
          end
        end
      end
      ke1y = nil
    end
  end

  local getMenu = function()
    return {
      title = "{7ef3fa}* " .. (settings.parashute.enable and "{00ff66}" or "{ff0000}") .. "PARASHUTE {808080}[ALFA]",
      submenu = {
        {
          title = "Информация о модуле",
          onclick = function()
            sampShowDialog(
                    0,
                    "{7ef3fa}/edith v." .. thisScript().version .. ' - информация о модуле {00ff66}"PARASHUTE"',
                    "{00ff66}PARASHUTE{ffffff}\nПарашют в воздухе через /piss.\nПоведение при аномальных FPS не тестировалось.\nАктивация: {00ccff}" .. tostring(key.id_to_name(settings.parashute.key)) .. "{ffffff}.",
                    "Окей"
            )
          end
        },
        {
          title = "Включить: " .. tostring(settings.parashute.enable),
          onclick = function()
            settings.parashute.enable = not settings.parashute.enable
            inicfg.save(settings, "edith")
          end
        },
        {
          title = "Изменить клавишу, сейчас: " .. tostring(tostring(key.id_to_name(settings.parashute.key))),
          onclick = function()
            table.insert(tempThreads, lua_thread.create(changeparashutekey))
          end
        },
      }
    }
  end

  local description = function()
    return "{7ef3fa}* " .. (settings.parashute.enable and "{00ff66}" or "{ff0000}") .. "PARASHUTE - {ffffff}Парашют через /piss в воздухе. Активация: {00ccff}" .. tostring(key.id_to_name(settings.parashute.key)) .. "{ffffff}."
  end

  local enableAll = function()
    settings.parashute.enable = true
  end

  local disableAll = function()
    settings.parashute.enable = false
  end

  local defaults = {
    enable = false,
    key = 80
  }

  local onSendChat = function(message)
    sleep = os.clock() * 1000
  end

  local onSendCommand = function(cmd)
    sleep = os.clock() * 1000
  end

  return {
    main = mainThread,
    getMenu = getMenu,
    desc = description,
    enable = enableAll,
    disable = disableAll,
    defaults = defaults,
    onSendChat = onSendChat,
    onSendCommand = onSendCommand
  }
end
--------------------------------------------------------------------------------
------------------------------------VSPIWKA-------------------------------------
--------------------------------------------------------------------------------
function vspiwkaModule()
  local result1, id1 = 0, 0

  local sleep = 0

  local antiFlood = function()
    repeat
      wait(100)
      local res, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
      local ms = math.ceil(os.clock() * 1000 - sleep)
    until ms > 1200 and sampGetPlayerScore(id) >= 1 and not sampIsDialogActive() and not sampIsChatInputActive()
  end

  local mainThread = function()
    while true do
      wait(100)
      if settings.vspiwka.enable then
        if isKeyJustPressed(settings.vspiwka.key) then
          if not sampIsChatInputActive() and not isSampfuncsConsoleActive() and not sampIsDialogActive() and not isCharInAnyCar(playerPed) then
            result1, id1 = sampGetPlayerIdByCharHandle(playerPed)
            if result1 then
              antiFlood()
              sampSendChat("/anim 42")
              wait(200)
            end
          end
        end
      end
    end
  end

  local changevspiwkakey = function()
    sampShowDialog(
            989,
            "Изменение горячей клавиши активации vspiwka",
            'Нажмите "Окей", после чего нажмите нужную клавишу.\nНастройки будут изменены.',
            "Окей",
            "Закрыть"
    )
    while sampIsDialogActive(989) do
      wait(100)
    end
    local resultMain, buttonMain, typ = sampHasDialogRespond(989)
    if buttonMain == 1 then
      while ke1y == nil do
        wait(0)
        for i = 1, 200 do
          if isKeyDown(i) then
            settings.vspiwka.key = i
            sampAddChatMessage("Установлена новая горячая клавиша - " .. key.id_to_name(i), -1)
            addOneOffSound(0.0, 0.0, 0.0, 1052)
            inicfg.save(settings, "edith")
            ke1y = 1
            break
          end
        end
      end
      ke1y = nil
    end
  end

  local getMenu = function()
    return {
      title = "{7ef3fa}* " .. (settings.vspiwka.enable and "{00ff66}" or "{ff0000}") .. "VSPIWKA",
      submenu = {
        {
          title = "Информация о модуле",
          onclick = function()
            sampShowDialog(
                    0,
                    "{7ef3fa}/edith v." .. thisScript().version .. ' - информация о модуле {00ff66}"VSPIWKA"',
                    "{00ff66}VSPIWKA{ffffff}\nБинд на /anim 23, чтобы спрятать хитбокс.\nАктивация: {00ccff}" .. tostring(key.id_to_name(settings.vspiwka.key)) .. "{ffffff}.",
                    "Окей"
            )
          end
        },
        {
          title = "Включить: " .. tostring(settings.vspiwka.enable),
          onclick = function()
            settings.vspiwka.enable = not settings.vspiwka.enable
            inicfg.save(settings, "edith")
          end
        },
        {
          title = "Изменить клавишу, сейчас: " .. tostring(tostring(key.id_to_name(settings.vspiwka.key))),
          onclick = function()
            table.insert(tempThreads, lua_thread.create(changevspiwkakey))
          end
        },
      }
    }
  end

  local description = function()
    return "{7ef3fa}* " .. (settings.vspiwka.enable and "{00ff66}" or "{ff0000}") .. "VSPIWKA - {ffffff}Бинд на /anim 23, чтобы спрятать хитбокс. Активация: {00ccff}" .. tostring(key.id_to_name(settings.vspiwka.key)) .. "{ffffff}."
  end

  local enableAll = function()
    settings.vspiwka.enable = true
  end

  local disableAll = function()
    settings.vspiwka.enable = false
  end

  local defaults = {
    enable = false,
    key = 82
  }

  local onSendChat = function(message)
    sleep = os.clock() * 1000
  end

  local onSendCommand = function(cmd)
    sleep = os.clock() * 1000
  end

  return {
    main = mainThread,
    getMenu = getMenu,
    desc = description,
    enable = enableAll,
    disable = disableAll,
    defaults = defaults,
    onSendChat = onSendChat,
    onSendCommand = onSendCommand
  }
end
--------------------------------------------------------------------------------
------------------------------------WARNINGS------------------------------------
--------------------------------------------------------------------------------
function warningsModule()
  local Set = function(list)
    local set = {}
    for _, l in ipairs(list) do
      set[l] = true
    end
    return set
  end

  local skins_gos = Set { 165, 166, 280, 281, 282, 283, 284, 285, 286, 288, 300, 301, 302, 303, 304, 305, 306, 307, 309, 310, 311, 163, 164, 287, 191 }
  local skins_ghetto = Set { 114, 115, 116, 292, 41, 173, 174, 175, 226, 273, 105, 106, 107, 56, 269, 270, 271, 102, 103, 104, 195, 108, 109, 110, 190 }
  local skins_bikers = Set { 247, 248, 254, 100, 181, 178, 246 }

  local track_gos = {}
  local track_ghetto = {}
  local track_bikers = {}

  local chat_table = {}
  local res, id = 0, 0
  local check_nick = 0

  local setContains = function(set, key)
    return set[key] ~= nil
  end

  local removeFromSet = function(set, key)
    set[key] = nil
  end

  local sleep = 0

  local antiFlood = function()
    repeat
      wait(100)
      local res, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
      local ms = math.ceil(os.clock() * 1000 - sleep)
    until ms > 1200 and sampGetPlayerScore(id) >= 1 and not sampIsDialogActive() and not sampIsChatInputActive()
  end

  local mainThread = function()
    while true do
      wait(2500)
      if settings.warningsS.enable then
        chat_table = getAllChars()
        for k, v in pairs(chat_table) do
          res, id = sampGetPlayerIdByCharHandle(v)
          if res and isCharDead(v) == false then
            check_nick = sampGetPlayerNickname(id)
            if setContains(track_bikers, check_nick) then
              if isCharInArea2d(v, track_bikers[check_nick]["x"] - 150, track_bikers[check_nick]["y"] - 150, track_bikers[check_nick]["x"] + 150, track_bikers[check_nick]["y"] + 150, false) then
                local time = os.time(os.date("!*t")) - track_bikers[check_nick]["time"]
                if settings.warningsS.bikers and time < 300 then
                  sampAddChatMessage("[EDITH]: " .. check_nick .. "[" .. id .. "] (байкер) возможно РКшнул. С момента смерти прошло: " .. time .. "с", -1)
                end
                removeFromSet(track_bikers, check_nick)
              end
            elseif setContains(track_ghetto, check_nick) then
              if isCharInArea2d(v, track_ghetto[check_nick]["x"] - 150, track_ghetto[check_nick]["y"] - 150, track_ghetto[check_nick]["x"] + 150, track_ghetto[check_nick]["y"] + 150, false) then
                local time = os.time(os.date("!*t")) - track_ghetto[check_nick]["time"]
                if settings.warningsS.ghetto and time < 300 then
                  sampAddChatMessage("[EDITH]: " .. check_nick .. "[" .. id .. "] (бандит) возможно РКшнул. С момента смерти прошло: " .. time .. "с", -1)
                end
                removeFromSet(track_ghetto, check_nick)
              end
            elseif setContains(track_gos, check_nick) then
              if isCharInArea2d(v, track_gos[check_nick]["x"] - 150, track_gos[check_nick]["y"] - 150, track_gos[check_nick]["x"] + 150, track_gos[check_nick]["y"] + 150, false) then
                local time = os.time(os.date("!*t")) - track_gos[check_nick]["time"]
                if settings.warningsS.gos and time < 300 then
                  sampAddChatMessage("[EDITH]: " .. check_nick .. "[" .. id .. "] (госер) возможно РКшнул. С момента смерти прошло: " .. time .. "с", -1)
                end
                removeFromSet(track_gos, check_nick)
              end
            end
          end
        end
      end
    end
  end

  local getMenu = function()
    return {
      title = "{7ef3fa}* " .. (settings.warningsS.enable and "{00ff66}" or "{ff0000}") .. "WARNINGS {808080}[могут заварнить]",
      submenu = {
        {
          title = "Информация о модуле",
          onclick = function()
            sampShowDialog(
                    0,
                    "{7ef3fa}/edith v." .. thisScript().version .. ' - информация о модуле {00ff66}"WARNINGS"',
                    "{00ff66}WARNINGS{ffffff}\nВарнинги на рк.\nМодуль запоминает ники умерших госеров/байкеров/геттарей и координаты их смерти.\nЕсли в течение 5 минут они появляются в зоне 300x300 с центром в месте смерти, выводится уведомление в чат.\nМожно отключить уведомления для отдельных групп игроков: госеров/байкеров/геттарей.",
                    "Окей"
            )
          end
        },
        {
          title = "Включить: " .. tostring(settings.warningsS.enable),
          onclick = function()
            settings.warningsS.enable = not settings.warningsS.enable
            inicfg.save(settings, "edith")
          end
        },

        {
          title = " "
        },
        {
          title = "Отслеживать госников: " .. tostring(settings.warningsS.gos),
          onclick = function()
            settings.warningsS.gos = not settings.warningsS.gos
            inicfg.save(settings, "edith")
          end
        },
        {
          title = "Отслеживать гетто: " .. tostring(settings.warningsS.ghetto),
          onclick = function()
            settings.warningsS.ghetto = not settings.warningsS.ghetto
            inicfg.save(settings, "edith")
          end
        },
        {
          title = "Отслеживать байкеров: " .. tostring(settings.warningsS.bikers),
          onclick = function()
            settings.warningsS.bikers = not settings.warningsS.bikers
            inicfg.save(settings, "edith")
          end
        },
      }
    }
  end

  local description = function()
    return "{7ef3fa}* " .. (settings.warningsS.enable and "{00ff66}" or "{ff0000}") .. "WARNINGS [могут заварнить] - {ffffff}Варнинги на РК для отдельных групп игроков: байкеры/госы/гетто."
  end

  local enableAll = function()
    settings.warningsS.enable = true
  end

  local disableAll = function()
    settings.warningsS.enable = false
  end

  local defaults = {
    enable = false,
    bikers = false,
    gos = true,
    ghetto = false
  }

  local addToSet2 = function(set, key, x, y, z)
    set[key] = {}
    set[key]["time"] = os.time(os.date("!*t"))
    set[key]["x"] = x
    set[key]["y"] = y
    set[key]["z"] = z
  end

  local onPlayerDeath = function(pID)
    if settings.warningsS.enable then
      local result, ped = sampGetCharHandleBySampPlayerId(pID)
      if result then
        local skin = getCharModel(ped)
        local x, y, z = getCharCoordinates(ped)
        if skins_bikers[skin] then
          addToSet2(track_bikers, sampGetPlayerNickname(pID), x, y, z)
        elseif skins_ghetto[skin] then
          addToSet2(track_ghetto, sampGetPlayerNickname(pID), x, y, z)
        elseif skins_gos[skin] then
          addToSet2(track_gos, sampGetPlayerNickname(pID), x, y, z)
        end
      end
    end
  end

  local onSendChat = function(message)
    sleep = os.clock() * 1000
  end

  local onSendCommand = function(cmd)
    sleep = os.clock() * 1000
  end

  return {
    main = mainThread,
    getMenu = getMenu,
    desc = description,
    enable = enableAll,
    disable = disableAll,
    defaults = defaults,
    onPlayerDeath = onPlayerDeath,
    onSendChat = onSendChat,
    onSendCommand = onSendCommand
  }
end
--------------------------------------------------------------------------------
-------------------------------------KUNAI--------------------------------------
--------------------------------------------------------------------------------
function kunaiModule()
  local result1, id1 = 0, 0
  local ping = 0
  local length = 0
  local kk = 0
  local ww = 0

  local disconnect = function()
    local bs = raknetNewBitStream();
    raknetBitStreamWriteInt8(bs, 32)
    raknetSendBitStream(bs);
    raknetDeleteBitStream(bs);
  end

  local split = function(pString, pPattern)
    local Table = {} -- NOTE: use {n = 0} in Lua-5.0
    local fpat = "(.-)" .. pPattern
    local last_end = 1
    local s, e, cap = pString:find(fpat, 1)
    while s do
      if s ~= 1 or cap ~= "" then
        table.insert(Table, cap)
      end
      last_end = e + 1
      s, e, cap = pString:find(fpat, last_end)
    end
    if last_end <= #pString then
      cap = pString:sub(last_end)
      table.insert(Table, cap)
    end
    return Table
  end

  local mainThread = function()
    while true do
      wait(0)
      if settings.kunai.enable then
        if isKeyJustPressed(settings.kunai.key) then
          if not sampIsChatInputActive() and not isSampfuncsConsoleActive() and not sampIsDialogActive() then
            result1, id1 = sampGetPlayerIdByCharHandle(playerPed)
            ping = 0
            if result1 then
              ping = sampGetPlayerPing(id1)
            end
            length = 0
            for k, v in pairs(split(settings.kunai.string, "!n")) do
              length = length + 1
            end
            kk = 0
            for k, v in pairs(split(settings.kunai.string, "!n")) do
              kk = kk + 1
              sampSendChat(v)
              if kk < length then
                ww = ping * 3
                if ww < 200 then
                  wait(200)
                end
              else
                wait(0)
                disconnect()
                wait(300)
                pcall(sampProcessChatInput, "/q")
              end
            end
          end
        end
      end
    end
  end

  local changekunaikey = function()
    sampShowDialog(
            989,
            "Изменение горячей клавиши активации kunai",
            'Нажмите "Окей", после чего нажмите нужную клавишу.\nНастройки будут изменены.',
            "Окей",
            "Закрыть"
    )
    while sampIsDialogActive(989) do
      wait(100)
    end
    local resultMain, buttonMain, typ = sampHasDialogRespond(989)
    if buttonMain == 1 then
      while ke1y == nil do
        wait(0)
        for i = 1, 200 do
          if isKeyDown(i) then
            settings.kunai.key = i
            sampAddChatMessage("Установлена новая горячая клавиша - " .. key.id_to_name(i), -1)
            addOneOffSound(0.0, 0.0, 0.0, 1052)
            inicfg.save(settings, "edith")
            ke1y = 1
            break
          end
        end
      end
      ke1y = nil
    end
  end

  local getMenu = function()
    return {
      title = "{7ef3fa}* " .. (settings.kunai.enable and "{00ff66}" or "{ff0000}") .. "KUNAI",
      submenu = {
        {
          title = "Информация о модуле",
          onclick = function()
            sampShowDialog(
                    0,
                    "{7ef3fa}/edith v." .. thisScript().version .. ' - информация о модуле {00ff66}"KUNAI"',
                    "{00ff66}KUNAI{ffffff}\n/q с клоунской РП отыгровкой.\nАктивация: {00ccff}" .. tostring(key.id_to_name(settings.kunai.key)) .. "{ffffff}.",
                    "Окей"
            )
          end
        },
        {
          title = "Включить: " .. tostring(settings.kunai.enable),
          onclick = function()
            settings.kunai.enable = not settings.kunai.enable
            inicfg.save(settings, "edith")
          end
        },
        {
          title = " "
        },
        {
          title = "Изменить клавишу, сейчас: " .. tostring(tostring(key.id_to_name(settings.kunai.key))),
          onclick = function()
            table.insert(tempThreads, lua_thread.create(changekunaikey))
          end
        },
        {
          title = "Изменить текст, сейчас: " .. tostring(settings.kunai.string),
          onclick = function()
            sampShowDialog(
                    9827,
                    "Строка для KUNAI.",
                    string.format("Введите строку, которая будет отправляться в чат за несколько миллисекунд до вашего оффа.\n!n разделяет строки, но лучше не ставить больше 2х.\nВведите пустую строку, чтобы не отправлять ничего."),
                    "Выбрать",
                    "Закрыть",
                    1
            )
            sampSetCurrentDialogEditboxText(settings.kunai.string)
            while sampIsDialogActive() do
              wait(100)
            end
            local result, button, list, input = sampHasDialogRespond(9827)
            if button == 1 then
              settings.kunai.string = sampGetCurrentDialogEditboxText(9827)
            end
            inicfg.save(settings, "edith")
          end
        },
      }
    }
  end

  local description = function()
    return "{7ef3fa}* " .. (settings.kunai.enable and "{00ff66}" or "{ff0000}") .. "KUNAI - {ffffff}Отправляет /q с клоунской РП отыгровкой, применять для /q в трудных ситуациях."
  end

  local enableAll = function()
    settings.kunai.enable = true
  end

  local disableAll = function()
    settings.kunai.enable = false
  end

  local defaults = {
    enable = false,
    key = 0x24,
    string = "/me быстро складывает ручные печати и бросает кунай в сторону!nТехника Летящего Бога Грома"
  }

  return {
    main = mainThread,
    getMenu = getMenu,
    desc = description,
    enable = enableAll,
    disable = disableAll,
    defaults = defaults
  }
end
--------------------------------------------------------------------------------
------------------------------------DISCORD-------------------------------------
--------------------------------------------------------------------------------
function discordModule()
  local init = function()
    local file = getGameDirectory() .. "\\moonloader\\lib\\discord-rpc.dll"
    if not doesFileExist(file) then
      down_rpc = true
      downloadUrlToFile(remoteResourceURL .. "discord-rpc.dll", file,
              function(id, status, p1, p2)
                if status == dlstatus.STATUSEX_ENDDOWNLOAD then
                  down_rpc = false
                end
              end
      )
    end
  end

  init()

  local mainThread = function()
    if settings.discord.enable then
      local streets = {
        { "Загородный клуб «Ависпа»", -2667.810, -302.135, -28.831, -2646.400, -262.320, 71.169 },
        { "Международный аэропорт Истер-Бэй", -1315.420, -405.388, 15.406, -1264.400, -209.543, 25.406 },
        { "Загородный клуб «Ависпа»", -2550.040, -355.493, 0.000, -2470.040, -318.493, 39.700 },
        { "Международный аэропорт Истер-Бэй", -1490.330, -209.543, 15.406, -1264.400, -148.388, 25.406 },
        { "Гарсия", -2395.140, -222.589, -5.3, -2354.090, -204.792, 200.000 },
        { "Шейди-Кэбин", -1632.830, -2263.440, -3.0, -1601.330, -2231.790, 200.000 },
        { "Восточный Лос-Сантос", 2381.680, -1494.030, -89.084, 2421.030, -1454.350, 110.916 },
        { "Грузовое депо Лас-Вентураса", 1236.630, 1163.410, -89.084, 1277.050, 1203.280, 110.916 },
        { "Пересечение Блэкфилд", 1277.050, 1044.690, -89.084, 1315.350, 1087.630, 110.916 },
        { "Загородный клуб «Ависпа»", -2470.040, -355.493, 0.000, -2270.040, -318.493, 46.100 },
        { "Темпл", 1252.330, -926.999, -89.084, 1357.000, -910.170, 110.916 },
        { "Станция «Юнити»", 1692.620, -1971.800, -20.492, 1812.620, -1932.800, 79.508 },
        { "Грузовое депо Лас-Вентураса", 1315.350, 1044.690, -89.084, 1375.600, 1087.630, 110.916 },
        { "Лос-Флорес", 2581.730, -1454.350, -89.084, 2632.830, -1393.420, 110.916 },
        { "Казино «Морская звезда»", 2437.390, 1858.100, -39.084, 2495.090, 1970.850, 60.916 },
        { "Химзавод Истер-Бэй", -1132.820, -787.391, 0.000, -956.476, -768.027, 200.000 },
        { "Деловой район", 1370.850, -1170.870, -89.084, 1463.900, -1130.850, 110.916 },
        { "Восточная Эспаланда", -1620.300, 1176.520, -4.5, -1580.010, 1274.260, 200.000 },
        { "Станция «Маркет»", 787.461, -1410.930, -34.126, 866.009, -1310.210, 65.874 },
        { "Станция «Линден»", 2811.250, 1229.590, -39.594, 2861.250, 1407.590, 60.406 },
        { "Пересечение Монтгомери", 1582.440, 347.457, 0.000, 1664.620, 401.750, 200.000 },
        { "Мост «Фредерик»", 2759.250, 296.501, 0.000, 2774.250, 594.757, 200.000 },
        { "Станция «Йеллоу-Белл»", 1377.480, 2600.430, -21.926, 1492.450, 2687.360, 78.074 },
        { "Деловой район", 1507.510, -1385.210, 110.916, 1582.550, -1325.310, 335.916 },
        { "Джефферсон", 2185.330, -1210.740, -89.084, 2281.450, -1154.590, 110.916 },
        { "Малхолланд", 1318.130, -910.170, -89.084, 1357.000, -768.027, 110.916 },
        { "Загородный клуб «Ависпа»", -2361.510, -417.199, 0.000, -2270.040, -355.493, 200.000 },
        { "Джефферсон", 1996.910, -1449.670, -89.084, 2056.860, -1350.720, 110.916 },
        { "Западаная автострада Джулиус", 1236.630, 2142.860, -89.084, 1297.470, 2243.230, 110.916 },
        { "Джефферсон", 2124.660, -1494.030, -89.084, 2266.210, -1449.670, 110.916 },
        { "Северная автострада Джулиус", 1848.400, 2478.490, -89.084, 1938.800, 2553.490, 110.916 },
        { "Родео", 422.680, -1570.200, -89.084, 466.223, -1406.050, 110.916 },
        { "Станция «Крэнберри»", -2007.830, 56.306, 0.000, -1922.000, 224.782, 100.000 },
        { "Деловой район", 1391.050, -1026.330, -89.084, 1463.900, -926.999, 110.916 },
        { "Западный Рэдсэндс", 1704.590, 2243.230, -89.084, 1777.390, 2342.830, 110.916 },
        { "Маленькая Мексика", 1758.900, -1722.260, -89.084, 1812.620, -1577.590, 110.916 },
        { "Пересечение Блэкфилд", 1375.600, 823.228, -89.084, 1457.390, 919.447, 110.916 },
        { "Международный аэропорт Лос-Сантос", 1974.630, -2394.330, -39.084, 2089.000, -2256.590, 60.916 },
        { "Бекон-Хилл", -399.633, -1075.520, -1.489, -319.033, -977.516, 198.511 },
        { "Родео", 334.503, -1501.950, -89.084, 422.680, -1406.050, 110.916 },
        { "Ричман", 225.165, -1369.620, -89.084, 334.503, -1292.070, 110.916 },
        { "Деловой район", 1724.760, -1250.900, -89.084, 1812.620, -1150.870, 110.916 },
        { "Стрип", 2027.400, 1703.230, -89.084, 2137.400, 1783.230, 110.916 },
        { "Деловой район", 1378.330, -1130.850, -89.084, 1463.900, -1026.330, 110.916 },
        { "Пересечение Блэкфилд", 1197.390, 1044.690, -89.084, 1277.050, 1163.390, 110.916 },
        { "Конференц Центр", 1073.220, -1842.270, -89.084, 1323.900, -1804.210, 110.916 },
        { "Монтгомери", 1451.400, 347.457, -6.1, 1582.440, 420.802, 200.000 },
        { "Долина Фостер", -2270.040, -430.276, -1.2, -2178.690, -324.114, 200.000 },
        { "Часовня Блэкфилд", 1325.600, 596.349, -89.084, 1375.600, 795.010, 110.916 },
        { "Международный аэропорт Лос-Сантос", 2051.630, -2597.260, -39.084, 2152.450, -2394.330, 60.916 },
        { "Малхолланд", 1096.470, -910.170, -89.084, 1169.130, -768.027, 110.916 },
        { "Поле для гольфа «Йеллоу-Белл»", 1457.460, 2723.230, -89.084, 1534.560, 2863.230, 110.916 },
        { "Стрип", 2027.400, 1783.230, -89.084, 2162.390, 1863.230, 110.916 },
        { "Джефферсон", 2056.860, -1210.740, -89.084, 2185.330, -1126.320, 110.916 },
        { "Малхолланд", 952.604, -937.184, -89.084, 1096.470, -860.619, 110.916 },
        { "Альдеа-Мальвада", -1372.140, 2498.520, 0.000, -1277.590, 2615.350, 200.000 },
        { "Лас-Колинас", 2126.860, -1126.320, -89.084, 2185.330, -934.489, 110.916 },
        { "Лас-Колинас", 1994.330, -1100.820, -89.084, 2056.860, -920.815, 110.916 },
        { "Ричман", 647.557, -954.662, -89.084, 768.694, -860.619, 110.916 },
        { "Грузовое депо Лас-Вентураса", 1277.050, 1087.630, -89.084, 1375.600, 1203.280, 110.916 },
        { "Северная автострада Джулиус", 1377.390, 2433.230, -89.084, 1534.560, 2507.230, 110.916 },
        { "Уиллоуфилд", 2201.820, -2095.000, -89.084, 2324.000, -1989.900, 110.916 },
        { "Северная автострада Джулиус", 1704.590, 2342.830, -89.084, 1848.400, 2433.230, 110.916 },
        { "Темпл", 1252.330, -1130.850, -89.084, 1378.330, -1026.330, 110.916 },
        { "Маленькая Мексика", 1701.900, -1842.270, -89.084, 1812.620, -1722.260, 110.916 },
        { "Квинс", -2411.220, 373.539, 0.000, -2253.540, 458.411, 200.000 },
        { "Аэропорт Лас-Вентурас", 1515.810, 1586.400, -12.500, 1729.950, 1714.560, 87.500 },
        { "Ричман", 225.165, -1292.070, -89.084, 466.223, -1235.070, 110.916 },
        { "Темпл", 1252.330, -1026.330, -89.084, 1391.050, -926.999, 110.916 },
        { "Восточный Лос-Сантос", 2266.260, -1494.030, -89.084, 2381.680, -1372.040, 110.916 },
        { "Восточная автострада Джулиус", 2623.180, 943.235, -89.084, 2749.900, 1055.960, 110.916 },
        { "Уиллоуфилд", 2541.700, -1941.400, -89.084, 2703.580, -1852.870, 110.916 },
        { "Лас-Колинас", 2056.860, -1126.320, -89.084, 2126.860, -920.815, 110.916 },
        { "Восточная автострада Джулиус", 2625.160, 2202.760, -89.084, 2685.160, 2442.550, 110.916 },
        { "Родео", 225.165, -1501.950, -89.084, 334.503, -1369.620, 110.916 },
        { "Лас-Брухас", -365.167, 2123.010, -3.0, -208.570, 2217.680, 200.000 },
        { "Восточная автострада Джулиус", 2536.430, 2442.550, -89.084, 2685.160, 2542.550, 110.916 },
        { "Родео", 334.503, -1406.050, -89.084, 466.223, -1292.070, 110.916 },
        { "Вайнвуд", 647.557, -1227.280, -89.084, 787.461, -1118.280, 110.916 },
        { "Родео", 422.680, -1684.650, -89.084, 558.099, -1570.200, 110.916 },
        { "Северная автострада Джулиус", 2498.210, 2542.550, -89.084, 2685.160, 2626.550, 110.916 },
        { "Деловой район", 1724.760, -1430.870, -89.084, 1812.620, -1250.900, 110.916 },
        { "Родео", 225.165, -1684.650, -89.084, 312.803, -1501.950, 110.916 },
        { "Джефферсон", 2056.860, -1449.670, -89.084, 2266.210, -1372.040, 110.916 },
        { "Хэмптон-Барнс", 603.035, 264.312, 0.000, 761.994, 366.572, 200.000 },
        { "Темпл", 1096.470, -1130.840, -89.084, 1252.330, -1026.330, 110.916 },
        { "Мост «Кинкейд»", -1087.930, 855.370, -89.084, -961.950, 986.281, 110.916 },
        { "Пляж «Верона»", 1046.150, -1722.260, -89.084, 1161.520, -1577.590, 110.916 },
        { "Коммерческий район", 1323.900, -1722.260, -89.084, 1440.900, -1577.590, 110.916 },
        { "Малхолланд", 1357.000, -926.999, -89.084, 1463.900, -768.027, 110.916 },
        { "Родео", 466.223, -1570.200, -89.084, 558.099, -1385.070, 110.916 },
        { "Малхолланд", 911.802, -860.619, -89.084, 1096.470, -768.027, 110.916 },
        { "Малхолланд", 768.694, -954.662, -89.084, 952.604, -860.619, 110.916 },
        { "Южная автострада Джулиус", 2377.390, 788.894, -89.084, 2537.390, 897.901, 110.916 },
        { "Айдлвуд", 1812.620, -1852.870, -89.084, 1971.660, -1742.310, 110.916 },
        { "Океанские доки", 2089.000, -2394.330, -89.084, 2201.820, -2235.840, 110.916 },
        { "Коммерческий район", 1370.850, -1577.590, -89.084, 1463.900, -1384.950, 110.916 },
        { "Северная автострада Джулиус", 2121.400, 2508.230, -89.084, 2237.400, 2663.170, 110.916 },
        { "Темпл", 1096.470, -1026.330, -89.084, 1252.330, -910.170, 110.916 },
        { "Глен Парк", 1812.620, -1449.670, -89.084, 1996.910, -1350.720, 110.916 },
        { "Международный аэропорт Истер-Бэй", -1242.980, -50.096, 0.000, -1213.910, 578.396, 200.000 },
        { "Мост «Мартин»", -222.179, 293.324, 0.000, -122.126, 476.465, 200.000 },
        { "Стрип", 2106.700, 1863.230, -89.084, 2162.390, 2202.760, 110.916 },
        { "Уиллоуфилд", 2541.700, -2059.230, -89.084, 2703.580, -1941.400, 110.916 },
        { "Марина", 807.922, -1577.590, -89.084, 926.922, -1416.250, 110.916 },
        { "Аэропорт Лас-Вентурас", 1457.370, 1143.210, -89.084, 1777.400, 1203.280, 110.916 },
        { "Айдлвуд", 1812.620, -1742.310, -89.084, 1951.660, -1602.310, 110.916 },
        { "Восточная Эспаланда", -1580.010, 1025.980, -6.1, -1499.890, 1274.260, 200.000 },
        { "Деловой район", 1370.850, -1384.950, -89.084, 1463.900, -1170.870, 110.916 },
        { "Мост «Мако»", 1664.620, 401.750, 0.000, 1785.140, 567.203, 200.000 },
        { "Родео", 312.803, -1684.650, -89.084, 422.680, -1501.950, 110.916 },
        { "Площадь «Першинг»", 1440.900, -1722.260, -89.084, 1583.500, -1577.590, 110.916 },
        { "Малхолланд", 687.802, -860.619, -89.084, 911.802, -768.027, 110.916 },
        { "Мост «Гант»", -2741.070, 1490.470, -6.1, -2616.400, 1659.680, 200.000 },
        { "Лас-Колинас", 2185.330, -1154.590, -89.084, 2281.450, -934.489, 110.916 },
        { "Малхолланд", 1169.130, -910.170, -89.084, 1318.130, -768.027, 110.916 },
        { "Северная автострада Джулиус", 1938.800, 2508.230, -89.084, 2121.400, 2624.230, 110.916 },
        { "Коммерческий район", 1667.960, -1577.590, -89.084, 1812.620, -1430.870, 110.916 },
        { "Родео", 72.648, -1544.170, -89.084, 225.165, -1404.970, 110.916 },
        { "Рока-Эскаланте", 2536.430, 2202.760, -89.084, 2625.160, 2442.550, 110.916 },
        { "Родео", 72.648, -1684.650, -89.084, 225.165, -1544.170, 110.916 },
        { "Маркет", 952.663, -1310.210, -89.084, 1072.660, -1130.850, 110.916 },
        { "Лас-Колинас", 2632.740, -1135.040, -89.084, 2747.740, -945.035, 110.916 },
        { "Малхолланд", 861.085, -674.885, -89.084, 1156.550, -600.896, 110.916 },
        { "Кингс", -2253.540, 373.539, -9.1, -1993.280, 458.411, 200.000 },
        { "Восточный Рэдсэндс", 1848.400, 2342.830, -89.084, 2011.940, 2478.490, 110.916 },
        { "Деловой район", -1580.010, 744.267, -6.1, -1499.890, 1025.980, 200.000 },
        { "Конференц Центр", 1046.150, -1804.210, -89.084, 1323.900, -1722.260, 110.916 },
        { "Ричман", 647.557, -1118.280, -89.084, 787.461, -954.662, 110.916 },
        { "Оушен-Флэтс", -2994.490, 277.411, -9.1, -2867.850, 458.411, 200.000 },
        { "Колледж Грингласс", 964.391, 930.890, -89.084, 1166.530, 1044.690, 110.916 },
        { "Глен Парк", 1812.620, -1100.820, -89.084, 1994.330, -973.380, 110.916 },
        { "Грузовое депо Лас-Вентураса", 1375.600, 919.447, -89.084, 1457.370, 1203.280, 110.916 },
        { "Регьюлар-Том", -405.770, 1712.860, -3.0, -276.719, 1892.750, 200.000 },
        { "Пляж «Верона»", 1161.520, -1722.260, -89.084, 1323.900, -1577.590, 110.916 },
        { "Восточный Лос-Сантос", 2281.450, -1372.040, -89.084, 2381.680, -1135.040, 110.916 },
        { "Дворец Калигулы", 2137.400, 1703.230, -89.084, 2437.390, 1783.230, 110.916 },
        { "Айдлвуд", 1951.660, -1742.310, -89.084, 2124.660, -1602.310, 110.916 },
        { "Пилигрим", 2624.400, 1383.230, -89.084, 2685.160, 1783.230, 110.916 },
        { "Айдлвуд", 2124.660, -1742.310, -89.084, 2222.560, -1494.030, 110.916 },
        { "Квинс", -2533.040, 458.411, 0.000, -2329.310, 578.396, 200.000 },
        { "Деловой район", -1871.720, 1176.420, -4.5, -1620.300, 1274.260, 200.000 },
        { "Коммерческий район", 1583.500, -1722.260, -89.084, 1758.900, -1577.590, 110.916 },
        { "Восточный Лос-Сантос", 2381.680, -1454.350, -89.084, 2462.130, -1135.040, 110.916 },
        { "Марина", 647.712, -1577.590, -89.084, 807.922, -1416.250, 110.916 },
        { "Ричман", 72.648, -1404.970, -89.084, 225.165, -1235.070, 110.916 },
        { "Вайнвуд", 647.712, -1416.250, -89.084, 787.461, -1227.280, 110.916 },
        { "Восточный Лос-Сантос", 2222.560, -1628.530, -89.084, 2421.030, -1494.030, 110.916 },
        { "Родео", 558.099, -1684.650, -89.084, 647.522, -1384.930, 110.916 },
        { "Истерский Тоннель", -1709.710, -833.034, -1.5, -1446.010, -730.118, 200.000 },
        { "Родео", 466.223, -1385.070, -89.084, 647.522, -1235.070, 110.916 },
        { "Восточный Рэдсэндс", 1817.390, 2202.760, -89.084, 2011.940, 2342.830, 110.916 },
        { "Казино «Карман клоуна»", 2162.390, 1783.230, -89.084, 2437.390, 1883.230, 110.916 },
        { "Айдлвуд", 1971.660, -1852.870, -89.084, 2222.560, -1742.310, 110.916 },
        { "Пересечение Монтгомери", 1546.650, 208.164, 0.000, 1745.830, 347.457, 200.000 },
        { "Уиллоуфилд", 2089.000, -2235.840, -89.084, 2201.820, -1989.900, 110.916 },
        { "Темпл", 952.663, -1130.840, -89.084, 1096.470, -937.184, 110.916 },
        { "Прикл-Пайн", 1848.400, 2553.490, -89.084, 1938.800, 2863.230, 110.916 },
        { "Международный аэропорт Лос-Сантос", 1400.970, -2669.260, -39.084, 2189.820, -2597.260, 60.916 },
        { "Мост «Гарвер»", -1213.910, 950.022, -89.084, -1087.930, 1178.930, 110.916 },
        { "Мост «Гарвер»", -1339.890, 828.129, -89.084, -1213.910, 1057.040, 110.916 },
        { "Мост «Кинкейд»", -1339.890, 599.218, -89.084, -1213.910, 828.129, 110.916 },
        { "Мост «Кинкейд»", -1213.910, 721.111, -89.084, -1087.930, 950.022, 110.916 },
        { "Пляж «Верона»", 930.221, -2006.780, -89.084, 1073.220, -1804.210, 110.916 },
        { "Обсерватория «Зелёный утёс»", 1073.220, -2006.780, -89.084, 1249.620, -1842.270, 110.916 },
        { "Вайнвуд", 787.461, -1130.840, -89.084, 952.604, -954.662, 110.916 },
        { "Вайнвуд", 787.461, -1310.210, -89.084, 952.663, -1130.840, 110.916 },
        { "Коммерческий район", 1463.900, -1577.590, -89.084, 1667.960, -1430.870, 110.916 },
        { "Маркет", 787.461, -1416.250, -89.084, 1072.660, -1310.210, 110.916 },
        { "Западный Рокшор", 2377.390, 596.349, -89.084, 2537.390, 788.894, 110.916 },
        { "Северная автострада Джулиус", 2237.400, 2542.550, -89.084, 2498.210, 2663.170, 110.916 },
        { "Восточный пляж", 2632.830, -1668.130, -89.084, 2747.740, -1393.420, 110.916 },
        { "Мост «Фаллоу»", 434.341, 366.572, 0.000, 603.035, 555.680, 200.000 },
        { "Уиллоуфилд", 2089.000, -1989.900, -89.084, 2324.000, -1852.870, 110.916 },
        { "Чайнатаун", -2274.170, 578.396, -7.6, -2078.670, 744.170, 200.000 },
        { "Эль-Кастильо-дель-Дьябло", -208.570, 2337.180, 0.000, 8.430, 2487.180, 200.000 },
        { "Океанские доки", 2324.000, -2145.100, -89.084, 2703.580, -2059.230, 110.916 },
        { "Химзавод Истер-Бэй", -1132.820, -768.027, 0.000, -956.476, -578.118, 200.000 },
        { "Казино «Визаж»", 1817.390, 1703.230, -89.084, 2027.400, 1863.230, 110.916 },
        { "Оушен-Флэтс", -2994.490, -430.276, -1.2, -2831.890, -222.589, 200.000 },
        { "Ричман", 321.356, -860.619, -89.084, 687.802, -768.027, 110.916 },
        { "Нефтяной комплекс «Зеленый оазис»", 176.581, 1305.450, -3.0, 338.658, 1520.720, 200.000 },
        { "Ричман", 321.356, -768.027, -89.084, 700.794, -674.885, 110.916 },
        { "Казино «Морская звезда»", 2162.390, 1883.230, -89.084, 2437.390, 2012.180, 110.916 },
        { "Восточный пляж", 2747.740, -1668.130, -89.084, 2959.350, -1498.620, 110.916 },
        { "Джефферсон", 2056.860, -1372.040, -89.084, 2281.450, -1210.740, 110.916 },
        { "Деловой район", 1463.900, -1290.870, -89.084, 1724.760, -1150.870, 110.916 },
        { "Деловой район", 1463.900, -1430.870, -89.084, 1724.760, -1290.870, 110.916 },
        { "Мост «Гарвер»", -1499.890, 696.442, -179.615, -1339.890, 925.353, 20.385 },
        { "Южная автострада Джулиус", 1457.390, 823.228, -89.084, 2377.390, 863.229, 110.916 },
        { "Восточный Лос-Сантос", 2421.030, -1628.530, -89.084, 2632.830, -1454.350, 110.916 },
        { "Колледж «Грингласс»", 964.391, 1044.690, -89.084, 1197.390, 1203.220, 110.916 },
        { "Лас-Колинас", 2747.740, -1120.040, -89.084, 2959.350, -945.035, 110.916 },
        { "Малхолланд", 737.573, -768.027, -89.084, 1142.290, -674.885, 110.916 },
        { "Океанские доки", 2201.820, -2730.880, -89.084, 2324.000, -2418.330, 110.916 },
        { "Восточный Лос-Сантос", 2462.130, -1454.350, -89.084, 2581.730, -1135.040, 110.916 },
        { "Гантон", 2222.560, -1722.330, -89.084, 2632.830, -1628.530, 110.916 },
        { "Загородный клуб «Ависпа»", -2831.890, -430.276, -6.1, -2646.400, -222.589, 200.000 },
        { "Уиллоуфилд", 1970.620, -2179.250, -89.084, 2089.000, -1852.870, 110.916 },
        { "Северная Эспланада", -1982.320, 1274.260, -4.5, -1524.240, 1358.900, 200.000 },
        { "Казино «Хай-Роллер»", 1817.390, 1283.230, -89.084, 2027.390, 1469.230, 110.916 },
        { "Океанские доки", 2201.820, -2418.330, -89.084, 2324.000, -2095.000, 110.916 },
        { "Мотель «Последний цент»", 1823.080, 596.349, -89.084, 1997.220, 823.228, 110.916 },
        { "Бэйсайнд-Марина", -2353.170, 2275.790, 0.000, -2153.170, 2475.790, 200.000 },
        { "Кингс", -2329.310, 458.411, -7.6, -1993.280, 578.396, 200.000 },
        { "Эль-Корона", 1692.620, -2179.250, -89.084, 1812.620, -1842.270, 110.916 },
        { "Часовня Блэкфилд", 1375.600, 596.349, -89.084, 1558.090, 823.228, 110.916 },
        { "«Розовый лебедь»", 1817.390, 1083.230, -89.084, 2027.390, 1283.230, 110.916 },
        { "Западаная автострада Джулиус", 1197.390, 1163.390, -89.084, 1236.630, 2243.230, 110.916 },
        { "Лос-Флорес", 2581.730, -1393.420, -89.084, 2747.740, -1135.040, 110.916 },
        { "Казино «Визаж»", 1817.390, 1863.230, -89.084, 2106.700, 2011.830, 110.916 },
        { "Прикл-Пайн", 1938.800, 2624.230, -89.084, 2121.400, 2861.550, 110.916 },
        { "Пляж «Верона»", 851.449, -1804.210, -89.084, 1046.150, -1577.590, 110.916 },
        { "Пересечение Робада", -1119.010, 1178.930, -89.084, -862.025, 1351.450, 110.916 },
        { "Линден-Сайд", 2749.900, 943.235, -89.084, 2923.390, 1198.990, 110.916 },
        { "Океанские доки", 2703.580, -2302.330, -89.084, 2959.350, -2126.900, 110.916 },
        { "Уиллоуфилд", 2324.000, -2059.230, -89.084, 2541.700, -1852.870, 110.916 },
        { "Кингс", -2411.220, 265.243, -9.1, -1993.280, 373.539, 200.000 },
        { "Коммерческий район", 1323.900, -1842.270, -89.084, 1701.900, -1722.260, 110.916 },
        { "Малхолланд", 1269.130, -768.027, -89.084, 1414.070, -452.425, 110.916 },
        { "Марина", 647.712, -1804.210, -89.084, 851.449, -1577.590, 110.916 },
        { "Бэттери-Пойнт", -2741.070, 1268.410, -4.5, -2533.040, 1490.470, 200.000 },
        { "Казино «4 Дракона»", 1817.390, 863.232, -89.084, 2027.390, 1083.230, 110.916 },
        { "Блэкфилд", 964.391, 1203.220, -89.084, 1197.390, 1403.220, 110.916 },
        { "Северная автострада Джулиус", 1534.560, 2433.230, -89.084, 1848.400, 2583.230, 110.916 },
        { "Поле для гольфа «Йеллоу-Белл»", 1117.400, 2723.230, -89.084, 1457.460, 2863.230, 110.916 },
        { "Айдлвуд", 1812.620, -1602.310, -89.084, 2124.660, -1449.670, 110.916 },
        { "Западный Рэдсэндс", 1297.470, 2142.860, -89.084, 1777.390, 2243.230, 110.916 },
        { "Доэрти", -2270.040, -324.114, -1.2, -1794.920, -222.589, 200.000 },
        { "Ферма Хиллтоп", 967.383, -450.390, -3.0, 1176.780, -217.900, 200.000 },
        { "Лас-Барранкас", -926.130, 1398.730, -3.0, -719.234, 1634.690, 200.000 },
        { "Казино «Пираты в мужских штанах»", 1817.390, 1469.230, -89.084, 2027.400, 1703.230, 110.916 },
        { "Сити Холл", -2867.850, 277.411, -9.1, -2593.440, 458.411, 200.000 },
        { "Загородный клуб «Ависпа»", -2646.400, -355.493, 0.000, -2270.040, -222.589, 200.000 },
        { "Стрип", 2027.400, 863.229, -89.084, 2087.390, 1703.230, 110.916 },
        { "Хашбери", -2593.440, -222.589, -1.0, -2411.220, 54.722, 200.000 },
        { "Международный аэропорт Лос-Сантос", 1852.000, -2394.330, -89.084, 2089.000, -2179.250, 110.916 },
        { "Уайтвуд-Истейтс", 1098.310, 1726.220, -89.084, 1197.390, 2243.230, 110.916 },
        { "Водохранилище Шермана", -789.737, 1659.680, -89.084, -599.505, 1929.410, 110.916 },
        { "Эль-Корона", 1812.620, -2179.250, -89.084, 1970.620, -1852.870, 110.916 },
        { "Деловой район", -1700.010, 744.267, -6.1, -1580.010, 1176.520, 200.000 },
        { "Долина Фостер", -2178.690, -1250.970, 0.000, -1794.920, -1115.580, 200.000 },
        { "Лас-Паясадас", -354.332, 2580.360, 2.0, -133.625, 2816.820, 200.000 },
        { "Долина Окультадо", -936.668, 2611.440, 2.0, -715.961, 2847.900, 200.000 },
        { "Пересечение Блэкфилд", 1166.530, 795.010, -89.084, 1375.600, 1044.690, 110.916 },
        { "Гантон", 2222.560, -1852.870, -89.084, 2632.830, -1722.330, 110.916 },
        { "Международный аэропорт Истер-Бэй", -1213.910, -730.118, 0.000, -1132.820, -50.096, 200.000 },
        { "Восточный Рэдсэндс", 1817.390, 2011.830, -89.084, 2106.700, 2202.760, 110.916 },
        { "Восточная Эспаланда", -1499.890, 578.396, -79.615, -1339.890, 1274.260, 20.385 },
        { "Дворец Калигулы", 2087.390, 1543.230, -89.084, 2437.390, 1703.230, 110.916 },
        { "Казино «Рояль»", 2087.390, 1383.230, -89.084, 2437.390, 1543.230, 110.916 },
        { "Ричман", 72.648, -1235.070, -89.084, 321.356, -1008.150, 110.916 },
        { "Казино «Морская звезда»", 2437.390, 1783.230, -89.084, 2685.160, 2012.180, 110.916 },
        { "Малхолланд", 1281.130, -452.425, -89.084, 1641.130, -290.913, 110.916 },
        { "Деловой район", -1982.320, 744.170, -6.1, -1871.720, 1274.260, 200.000 },
        { "Ханки-Панки-Пойнт", 2576.920, 62.158, 0.000, 2759.250, 385.503, 200.000 },
        { "Военный склад топлива К.А.С.С.", 2498.210, 2626.550, -89.084, 2749.900, 2861.550, 110.916 },
        { "Автострада «Гарри-Голд»", 1777.390, 863.232, -89.084, 1817.390, 2342.830, 110.916 },
        { "Тоннель Бэйсайд", -2290.190, 2548.290, -89.084, -1950.190, 2723.290, 110.916 },
        { "Океанские доки", 2324.000, -2302.330, -89.084, 2703.580, -2145.100, 110.916 },
        { "Ричман", 321.356, -1044.070, -89.084, 647.557, -860.619, 110.916 },
        { "Промсклад имени Рэндольфа", 1558.090, 596.349, -89.084, 1823.080, 823.235, 110.916 },
        { "Восточный пляж", 2632.830, -1852.870, -89.084, 2959.350, -1668.130, 110.916 },
        { "Флинт-Уотер", -314.426, -753.874, -89.084, -106.339, -463.073, 110.916 },
        { "Блуберри", 19.607, -404.136, 3.8, 349.607, -220.137, 200.000 },
        { "Станция «Линден»", 2749.900, 1198.990, -89.084, 2923.390, 1548.990, 110.916 },
        { "Глен Парк", 1812.620, -1350.720, -89.084, 2056.860, -1100.820, 110.916 },
        { "Деловой район", -1993.280, 265.243, -9.1, -1794.920, 578.396, 200.000 },
        { "Западный Рэдсэндс", 1377.390, 2243.230, -89.084, 1704.590, 2433.230, 110.916 },
        { "Ричман", 321.356, -1235.070, -89.084, 647.522, -1044.070, 110.916 },
        { "Мост «Гант»", -2741.450, 1659.680, -6.1, -2616.400, 2175.150, 200.000 },
        { "Бар «Probe Inn»", -90.218, 1286.850, -3.0, 153.859, 1554.120, 200.000 },
        { "Пересечение Флинт", -187.700, -1596.760, -89.084, 17.063, -1276.600, 110.916 },
        { "Лас-Колинас", 2281.450, -1135.040, -89.084, 2632.740, -945.035, 110.916 },
        { "Собелл-Рейл-Ярдс", 2749.900, 1548.990, -89.084, 2923.390, 1937.250, 110.916 },
        { "Изумрудный остров", 2011.940, 2202.760, -89.084, 2237.400, 2508.230, 110.916 },
        { "Эль-Кастильо-дель-Дьябло", -208.570, 2123.010, -7.6, 114.033, 2337.180, 200.000 },
        { "Санта-Флора", -2741.070, 458.411, -7.6, -2533.040, 793.411, 200.000 },
        { "Плайя-дель-Севиль", 2703.580, -2126.900, -89.084, 2959.350, -1852.870, 110.916 },
        { "Маркет", 926.922, -1577.590, -89.084, 1370.850, -1416.250, 110.916 },
        { "Квинс", -2593.440, 54.722, 0.000, -2411.220, 458.411, 200.000 },
        { "Пересечение Пилсон", 1098.390, 2243.230, -89.084, 1377.390, 2507.230, 110.916 },
        { "Спинибед", 2121.400, 2663.170, -89.084, 2498.210, 2861.550, 110.916 },
        { "Пилигрим", 2437.390, 1383.230, -89.084, 2624.400, 1783.230, 110.916 },
        { "Блэкфилд", 964.391, 1403.220, -89.084, 1197.390, 1726.220, 110.916 },
        { "«Большое ухо»", -410.020, 1403.340, -3.0, -137.969, 1681.230, 200.000 },
        { "Диллимор", 580.794, -674.885, -9.5, 861.085, -404.790, 200.000 },
        { "Эль-Кебрадос", -1645.230, 2498.520, 0.000, -1372.140, 2777.850, 200.000 },
        { "Северная Эспланада", -2533.040, 1358.900, -4.5, -1996.660, 1501.210, 200.000 },
        { "Международный аэропорт Истер-Бэй", -1499.890, -50.096, -1.0, -1242.980, 249.904, 200.000 },
        { "Рыбацкая лагуна", 1916.990, -233.323, -100.000, 2131.720, 13.800, 200.000 },
        { "Малхолланд", 1414.070, -768.027, -89.084, 1667.610, -452.425, 110.916 },
        { "Восточный пляж", 2747.740, -1498.620, -89.084, 2959.350, -1120.040, 110.916 },
        { "Сан-Андреас Саунд", 2450.390, 385.503, -100.000, 2759.250, 562.349, 200.000 },
        { "Тенистые ручьи", -2030.120, -2174.890, -6.1, -1820.640, -1771.660, 200.000 },
        { "Маркет", 1072.660, -1416.250, -89.084, 1370.850, -1130.850, 110.916 },
        { "Западный Рокшор", 1997.220, 596.349, -89.084, 2377.390, 823.228, 110.916 },
        { "Прикл-Пайн", 1534.560, 2583.230, -89.084, 1848.400, 2863.230, 110.916 },
        { "«Бухта Пасхи»", -1794.920, -50.096, -1.04, -1499.890, 249.904, 200.000 },
        { "Лифи-Холлоу", -1166.970, -1856.030, 0.000, -815.624, -1602.070, 200.000 },
        { "Грузовое депо Лас-Вентураса", 1457.390, 863.229, -89.084, 1777.400, 1143.210, 110.916 },
        { "Прикл-Пайн", 1117.400, 2507.230, -89.084, 1534.560, 2723.230, 110.916 },
        { "Блуберри", 104.534, -220.137, 2.3, 349.607, 152.236, 200.000 },
        { "Эль-Кастильо-дель-Дьябло", -464.515, 2217.680, 0.000, -208.570, 2580.360, 200.000 },
        { "Деловой район", -2078.670, 578.396, -7.6, -1499.890, 744.267, 200.000 },
        { "Восточный Рокшор", 2537.390, 676.549, -89.084, 2902.350, 943.235, 110.916 },
        { "Залив Сан-Фиерро", -2616.400, 1501.210, -3.0, -1996.660, 1659.680, 200.000 },
        { "Парадизо", -2741.070, 793.411, -6.1, -2533.040, 1268.410, 200.000 },
        { "Казино «Носок верблюда»", 2087.390, 1203.230, -89.084, 2640.400, 1383.230, 110.916 },
        { "Олд-Вентурас-Стрип", 2162.390, 2012.180, -89.084, 2685.160, 2202.760, 110.916 },
        { "Джанипер-Хилл", -2533.040, 578.396, -7.6, -2274.170, 968.369, 200.000 },
        { "Джанипер-Холлоу", -2533.040, 968.369, -6.1, -2274.170, 1358.900, 200.000 },
        { "Рока-Эскаланте", 2237.400, 2202.760, -89.084, 2536.430, 2542.550, 110.916 },
        { "Восточная автострада Джулиус", 2685.160, 1055.960, -89.084, 2749.900, 2626.550, 110.916 },
        { "Пляж «Верона»", 647.712, -2173.290, -89.084, 930.221, -1804.210, 110.916 },
        { "Долина Фостер", -2178.690, -599.884, -1.2, -1794.920, -324.114, 200.000 },
        { "Арко-дель-Оэсте", -901.129, 2221.860, 0.000, -592.090, 2571.970, 200.000 },
        { "«Упавшее дерево»", -792.254, -698.555, -5.3, -452.404, -380.043, 200.000 },
        { "Ферма", -1209.670, -1317.100, 114.981, -908.161, -787.391, 251.981 },
        { "Дамба Шермана", -968.772, 1929.410, -3.0, -481.126, 2155.260, 200.000 },
        { "Северная Эспланада", -1996.660, 1358.900, -4.5, -1524.240, 1592.510, 200.000 },
        { "Финансовый район", -1871.720, 744.170, -6.1, -1701.300, 1176.420, 300.000 },
        { "Гарсия", -2411.220, -222.589, -1.14, -2173.040, 265.243, 200.000 },
        { "Монтгомери", 1119.510, 119.526, -3.0, 1451.400, 493.323, 200.000 },
        { "Крик", 2749.900, 1937.250, -89.084, 2921.620, 2669.790, 110.916 },
        { "Международный аэропорт Лос-Сантос", 1249.620, -2394.330, -89.084, 1852.000, -2179.250, 110.916 },
        { "Пляж «Санта-Мария»", 72.648, -2173.290, -89.084, 342.648, -1684.650, 110.916 },
        { "Пересечение Малхолланд", 1463.900, -1150.870, -89.084, 1812.620, -768.027, 110.916 },
        { "Эйнджел-Пайн", -2324.940, -2584.290, -6.1, -1964.220, -2212.110, 200.000 },
        { "Вёрдант-Медоус", 37.032, 2337.180, -3.0, 435.988, 2677.900, 200.000 },
        { "Октан-Спрингс", 338.658, 1228.510, 0.000, 664.308, 1655.050, 200.000 },
        { "Казино Кам-э-Лот", 2087.390, 943.235, -89.084, 2623.180, 1203.230, 110.916 },
        { "Западный Рэдсэндс", 1236.630, 1883.110, -89.084, 1777.390, 2142.860, 110.916 },
        { "Пляж «Санта-Мария»", 342.648, -2173.290, -89.084, 647.712, -1684.650, 110.916 },
        { "Обсерватория «Зелёный утёс»", 1249.620, -2179.250, -89.084, 1692.620, -1842.270, 110.916 },
        { "Аэропорт Лас-Вентурас", 1236.630, 1203.280, -89.084, 1457.370, 1883.110, 110.916 },
        { "Округ Флинт", -594.191, -1648.550, 0.000, -187.700, -1276.600, 200.000 },
        { "Обсерватория «Зелёный утёс»", 930.221, -2488.420, -89.084, 1249.620, -2006.780, 110.916 },
        { "Паломино Крик", 2160.220, -149.004, 0.000, 2576.920, 228.322, 200.000 },
        { "Океанские доки", 2373.770, -2697.090, -89.084, 2809.220, -2330.460, 110.916 },
        { "Международный аэропорт Истер-Бэй", -1213.910, -50.096, -4.5, -947.980, 578.396, 200.000 },
        { "Уайтвуд-Истейтс", 883.308, 1726.220, -89.084, 1098.310, 2507.230, 110.916 },
        { "Калтон-Хайтс", -2274.170, 744.170, -6.1, -1982.320, 1358.900, 200.000 },
        { "«Бухта Пасхи»", -1794.920, 249.904, -9.1, -1242.980, 578.396, 200.000 },
        { "Залив Лос-Сантос", -321.744, -2224.430, -89.084, 44.615, -1724.430, 110.916 },
        { "Доэрти", -2173.040, -222.589, -1.0, -1794.920, 265.243, 200.000 },
        { "Гора Чилиад", -2178.690, -2189.910, -47.917, -2030.120, -1771.660, 576.083 },
        { "Форт-Карсон", -376.233, 826.326, -3.0, 123.717, 1220.440, 200.000 },
        { "Долина Фостер", -2178.690, -1115.580, 0.000, -1794.920, -599.884, 200.000 },
        { "Оушен-Флэтс", -2994.490, -222.589, -1.0, -2593.440, 277.411, 200.000 },
        { "Ферн-Ридж", 508.189, -139.259, 0.000, 1306.660, 119.526, 200.000 },
        { "Бэйсайд", -2741.070, 2175.150, 0.000, -2353.170, 2722.790, 200.000 },
        { "Аэропорт Лас-Вентурас", 1457.370, 1203.280, -89.084, 1777.390, 1883.110, 110.916 },
        { "Поместье Блуберри", -319.676, -220.137, 0.000, 104.534, 293.324, 200.000 },
        { "Пэлисейдс", -2994.490, 458.411, -6.1, -2741.070, 1339.610, 200.000 },
        { "Норт-Рок", 2285.370, -768.027, 0.000, 2770.590, -269.740, 200.000 },
        { "Карьер «Хантер»", 337.244, 710.840, -115.239, 860.554, 1031.710, 203.761 },
        { "Международный аэропорт Лос-Сантос", 1382.730, -2730.880, -89.084, 2201.820, -2394.330, 110.916 },
        { "Миссионер-Хилл", -2994.490, -811.276, 0.000, -2178.690, -430.276, 200.000 },
        { "Залив Сан-Фиерро", -2616.400, 1659.680, -3.0, -1996.660, 2175.150, 200.000 },
        { "Запретная Зона", -91.586, 1655.050, -50.000, 421.234, 2123.010, 250.000 },
        { "Гора «Чилиад»", -2997.470, -1115.580, -47.917, -2178.690, -971.913, 576.083 },
        { "Гора «Чилиад»", -2178.690, -1771.660, -47.917, -1936.120, -1250.970, 576.083 },
        { "Международный аэропорт Истер-Бэй", -1794.920, -730.118, -3.0, -1213.910, -50.096, 200.000 },
        { "Паноптикум", -947.980, -304.320, -1.1, -319.676, 327.071, 200.000 },
        { "Тенистые ручьи", -1820.640, -2643.680, -8.0, -1226.780, -1771.660, 200.000 },
        { "Бэк-о-Бейонд", -1166.970, -2641.190, 0.000, -321.744, -1856.030, 200.000 },
        { "Гора «Чилиад»", -2994.490, -2189.910, -47.917, -2178.690, -1115.580, 576.083 },
        { "Тьерра Робада", -1213.910, 596.349, -242.990, -480.539, 1659.680, 900.000 },
        { "Округ Флинт", -1213.910, -2892.970, -242.990, 44.615, -768.027, 900.000 },
        { "Уэтстоун", -2997.470, -2892.970, -242.990, -1213.910, -1115.580, 900.000 },
        { "Пустынный округ", -480.539, 596.349, -242.990, 869.461, 2993.870, 900.000 },
        { "Тьерра Робада", -2997.470, 1659.680, -242.990, -480.539, 2993.870, 900.000 },
        { "Сан Фиерро", -2997.470, -1115.580, -242.990, -1213.910, 1659.680, 900.000 },
        { "Лас Вентурас", 869.461, 596.349, -242.990, 2997.060, 2993.870, 900.000 },
        { "Туманный округ", -1213.910, -768.027, -242.990, 2997.060, 596.349, 900.000 },
        { "Лос Сантос", 44.615, -2892.970, -242.990, 2997.060, -768.027, 900.000 },
        { "Форт ДеМорган", 2234, -6460, 0, 2380, -6320, 30 }
      }

      local int2 = {
        { "LSPD/LVPD", 1096, -864, 1000, 1280, -707, 1200 },
        { "SFPD", 700, 2556, 1000, 800, 2650, 1200 }
      }

      local function calculateZoneRU(x, y, z)
        if getActiveInterior() == 2 then
          x, y, z = getCharCoordinates(playerPed)
          for i, v in ipairs(int2) do
            if (x >= v[2]) and (y >= v[3]) and (z >= v[4]) and (x <= v[5]) and (y <= v[6]) and (z <= v[7]) then
              return v[1]
            end
          end
        else
          if x == 0 and y == 0 and z == 0 then
            return "Неизвестно"
          end
          for i, v in ipairs(streets) do
            if (x >= v[2]) and (y >= v[3]) and (z >= v[4]) and (x <= v[5]) and (y <= v[6]) and (z <= v[7]) then
              return v[1]
            end
          end
        end
        return 'Неизвестно'
      end

      ffi.cdef([[
    typedef struct {
      const char* state;
      const char* details;
      int64_t startTimestamp;
      int64_t endTimestamp;
      const char* largeImageKey;
      const char* largeImageText;
      const char* smallImageKey;
      const char* smallImageText;
      const char* partyId;
      int partySize;
      int partyMax;
      const char* matchSecret;
      const char* joinSecret;
      const char* spectateSecret;
      int8_t instance;
    } DiscordRichPresence;

    void Discord_Initialize(const char* applicationId,
          int handlers,
          int autoRegister,
          const char* optionalSteamId);

    void Discord_UpdatePresence(const DiscordRichPresence* presence);

    typedef struct {
      int type;
      int state;
      int ammoInClip;
      int totalAmmo;
      char field_10[0x0C];
    } CWeapon;

    typedef struct {
      char field_0[0x544];
      float maxHealth;
      char field_548[0x58];
      CWeapon weapons[13];
    } CPed;
  ]])

      local weapons = {
        [0] = "Кулак",
        [1] = "Кастет",
        [2] = "Клюшка для гольфа",
        [3] = "Полицейская дубинка",
        [4] = "Нож",
        [5] = "Бейсбольная бита",
        [6] = "Лопата",
        [7] = "Кий",
        [8] = "Катана",
        [9] = "Бензопила",
        [10] = "Двухсторонний дилдо",
        [11] = "Короткий вибратор",
        [12] = "Длинный вибратор",
        [13] = "Белый фаллоимитатор",
        [14] = "Цветы",
        [15] = "Трость",
        [16] = "Граната",
        [17] = "Слезоточивый газ",
        [18] = "Коктейль Молотова",
        [19] = "Unused",
        [20] = "Unused",
        [21] = "Unused",
        [22] = "Пистолет 9мм",
        [23] = "Пистолет с глушителем",
        [24] = "Пустынный орёл",
        [25] = "Дробовик",
        [26] = "Обрез",
        [27] = "Скорострельный дробовик",
        [28] = "Узи",
        [29] = "МР5",
        [30] = "AK-47",
        [31] = "M4",
        [32] = "Tec-9",
        [33] = "Охотничье ружье",
        [34] = "Снайперская винтовка",
        [35] = "РПГ",
        [36] = "Самонаводящиеся ракеты",
        [37] = "Огнемет",
        [38] = "Миниган",
        [39] = "Сумка с тротилом",
        [40] = "Детонатор",
        [41] = "Баллончик с краской",
        [42] = "Огнетушитель",
        [43] = "Камера",
        [44] = "Прибор ночного видения",
        [45] = "Тепловизор",
        [46] = "Парашют",
        [47] = "Fake Pistol",
        --  [ID] = "Weapon Name",
      }
      while down_rpc do
        wait(100)
      end
      local result, drpc = pcall(ffi.load, "moonloader/lib/discord-rpc.dll")
      if not result then
        sampAddChatMessage("Ошибка загрузки discord-rpc.dll, отключите модуль DISCORD или решите проблему.", -1)
        return
      end
      local rpc = ffi.new("DiscordRichPresence")

      local pX, pY, pZ = 0, 0, 0

      local function comma_value(n)
        local left, num, right = string.match(n, '^([^%d]*%d)(%d*)(.-)$')
        return left .. (num:reverse():gsub('(%d%d%d)', '%1.'):reverse()) .. right
      end

      local function separator(text)
        for S in string.gmatch(getPlayerMoney(PlayerPed), "%d+") do
          local replace = comma_value(S)
          text = string.gsub(getPlayerMoney(PlayerPed), S, replace)
        end

        return text
      end

      drpc.Discord_Initialize("542214983115866116", 0, 0, "")
      if not isSampfuncsLoaded() or not isSampLoaded() then
        return
      end
      while not isSampAvailable() do
        wait(0)
      end

      rpc.startTimestamp = os.time()

      local stat = getIntStat(121)
      local time = os.time()
      local flag = true
      local samp = 0

      if isSampLoaded() then
        if isSampfuncsLoaded() then
          samp = 2
        else
          print("Sampfuncs required to work on samp mode.")
          samp = 1
        end
      end

      local cped = ffi.cast("CPed*", getCharPointer(playerPed))

      local state = 0
      local _, myid = 0, 0
      local ip, port = 0, 0
      local res, wLevel = 0, 0
      local stars = 0
      local _, myid = 0, 0
      local zone = 0
      local show = 0

      local armour = 0
      local maxArmour = 0

      local health = 0
      local maxHealth = 0

      local currWeap = 0
      local wpName = 0

      local slot = 0
      local clip = 0
      local total = 0

      while true do
        if isCharDead(playerPed) or hasCharBeenArrested(playerPed) then
          rpc.largeImageKey = "game_icon_" .. (isCharDead(playerPed) and "wasted" or "busted")
        else
          rpc.largeImageKey = (samp >= 1 and "samp" or "game") .. "_icon"
        end

        if flag then
          if samp == 2 then
            local gameState = {
              "Не понятно",
              "Ожидает соединения",
              "Подключается",
              "Подключился",
              "Рестарт сервера",
              "Отключен от сервера"
            }

            state = sampGetGamestate()

            if state == 3 or state == 4 then
              _, myid = sampGetPlayerIdByCharHandle(playerPed)
              rpc.state = "" .. sampGetPlayerNickname(myid) .. '[' .. myid .. ']'
            else
              rpc.state = u8:encode("Статус: " .. gameState[sampGetGamestate()])
            end

            ip, port = sampGetCurrentServerAddress()
            if string.find(sampGetCurrentServerName(), "Revolution") then
              rpc.details = u8:encode("Samp-Rp Revolution")
            else
              rpc.details = u8:decode(sampGetCurrentServerName())
            end
          elseif samp == 0 then
            res, wLevel = storeWantedLevel(playerHandle)
            stars = ""

            if wLevel > 0 then
              for i = 1, wLevel do
                stars = stars .. "?"
              end
            else
              stars = "0"
            end

            rpc.state = u8:encode("Уровень розыска: " .. stars)
            rpc.details = u8:encode("Убийств: " .. getIntStat(121) - stat)
          end

          if settings.discord.more and os.time() > time + 5 then
            flag = false
            time = os.time()
          end
        else
          _, myid = sampGetPlayerIdByCharHandle(playerPed)
          if getActiveInterior() == 0 and sampGetPlayerScore(myid) >= 1 then
            pX, pY, pZ = getCharCoordinates(playerPed)
          end

          zone = calculateZoneRU(pX, pY, pZ)

          if settings.discord.free then
            if zone ~= "LSPD/LVPD" and zone ~= "Форт ДеМорган" then
              zone = "Наслаждается свободой"
            end
          end
          show = false

          if samp == 2 then
            state = sampGetGamestate()

            if state == 3 or state == 4 then
              show = true
            end
          else
            show = true
          end

          if show then
            if isCharSittingInAnyCar(playerPed) then
              rpc.state = u8:encode(string.format("Едет в %s", zone))
            else
              rpc.state = u8:encode(string.format("%s", zone))
            end

            rpc.details = u8:encode("Деньги: $" .. separator(text))
          end

          if settings.discord.more and os.time() > time + 5 then
            flag = true
            time = os.time()
          end
        end

        armour = getCharArmour(playerPed)
        maxArmour = getPlayerMaxArmour(playerHandle)

        health = getCharHealth(playerPed)
        maxHealth = cped.maxHealth

        if armour > 0 then
          rpc.largeImageText = string.format("AR: %.01f / %.01f Health: %.01f / %.01f",
                  armour, maxArmour, health, maxHealth)
        else
          rpc.largeImageText = string.format("HP: %.01f / %.01f", health, maxHealth)
        end

        currWeap = getCurrentCharWeapon(playerPed)
        wpName = weapons[currWeap] or ""

        rpc.smallImageKey = "weap_" .. (wpName ~= "" and currWeap or "added")

        slot = getWeapontypeSlot(currWeap)
        clip = cped.weapons[slot].ammoInClip
        total = cped.weapons[slot].totalAmmo

        if slot <= 1 or slot >= 10 then
          rpc.smallImageText = u8:encode(wpName)
        end

        if slot == 3 or slot == 6 or slot == 7 or slot == 8 then
          rpc.smallImageText = u8:encode(string.format("%s %d", wpName, total))
        end

        if slot == 2 or slot == 4 or slot == 5 or slot == 9 then
          rpc.smallImageText = u8:encode(string.format("%s %d / %d", wpName, clip, total - clip))
        end

        drpc.Discord_UpdatePresence(rpc)
        wait(150)
      end
    end
  end

  local getMenu = function()
    return {
      title = "{7ef3fa}* " .. (settings.discord.enable and "{00ff66}" or "{ff0000}") .. "DISCORD",
      submenu = {
        {
          title = "Информация о модуле",
          onclick = function()
            sampShowDialog(
                    0,
                    "{7ef3fa}/edith v." .. thisScript().version .. ' - информация о модуле {00ff66}"DISCORD"',
                    "{00ff66}DISCORD{ffffff}\nОбновляет ваш статус в дискорде информацией об игре.{ffffff}.",
                    "Окей"
            )
          end
        },
        {
          title = "Включить: " .. tostring(settings.discord.enable),
          onclick = function()
            settings.discord.enable = not settings.discord.enable
            inicfg.save(settings, "edith")
            thisScript():reload()
          end
        },
        {
          title = "Больше информации (деньги, местоположение): " .. tostring(settings.discord.more),
          onclick = function()
            settings.discord.more = not settings.discord.more
            inicfg.save(settings, "edith")
          end
        },
        {
          title = "Ограничить местоположение до в КПЗ/ДМ или на свободе: " .. tostring(settings.discord.more),
          onclick = function()
            settings.discord.free = not settings.discord.free
            inicfg.save(settings, "edith")
          end
        },
      }
    }
  end

  local description = function()
    return "{7ef3fa}* " .. (settings.discord.enable and "{00ff66}" or "{ff0000}") .. "DISCORD - {ffffff}Обновляет Rich Presence дискорда, дополняя его самповской информацией."
  end

  local enableAll = function()
    settings.discord.enable = true
  end

  local disableAll = function()
    settings.discord.enable = false
  end

  local defaults = {
    enable = false,
    more = false,
    free = true
  }

  return {
    main = mainThread,
    getMenu = getMenu,
    desc = description,
    enable = enableAll,
    disable = disableAll,
    defaults = defaults
  }
end
--------------------------------------------------------------------------------
-----------------------------------DEATHLIST------------------------------------
--------------------------------------------------------------------------------
function deathListModule()
  local deathlist_timestamp = 0

  local killedBitches = {}
  local woundedBitches = {}

  local deathListTable = {}

  local lastKilledBy = ""

  local damage_col = 0
  local damage_col_in = 0

  local weap = 0
  local enemyWeap = 0

  local terra = false
  local terra_id = 0

  local tpmp = false

  local dmg_timing = os.clock()
  local deathListTiming = os.clock()

  local res, killedId, killedNick = 0, 0, 0

  local bs = 0

  local asodkas, licenseid = sampGetPlayerIdByCharHandle(PLAYER_PED)
  local licensenick = sampGetPlayerNickname(licenseid)

  local sampGetPlayerIdByNickname = function(nick)
    local _, myid = sampGetPlayerIdByCharHandle(playerPed)
    if tostring(nick) == sampGetPlayerNickname(myid) then
      return myid
    end
    for i = 0, 1000 do
      if sampIsPlayerConnected(i) and sampGetPlayerNickname(i) == tostring(nick) then
        return i
      end
    end
    return nil
  end

  local isArenaActive = function()
    if getActiveInterior() == 0 then
      local x, y, z = getCharCoordinates(playerPed)
      if z > 500 then
        return true
      else
        return false
      end
    else
      return false
    end
  end

  local mainThread = function()
    if not isSampLoaded() then
      return
    end
    while not isSampAvailable() do
      wait(100)
    end
    while true do
      wait(0)
      if isCharDead(playerPed) then
        wait(250)
        res, killedId = sampGetPlayerIdByCharHandle(PLAYER_PED)
        if res and tpmp == false and not isArenaActive() then
          killedNick = sampGetPlayerNickname(killedId)

          if settings.deathlist.debug then
            sampAddChatMessage("меня убил " .. killedNick, -1)
          end

          table.insert(deathListTable, {
            killerNick = lastKilledBy,
            killedNick = killedNick,
            weapon = enemyWeap,
            type = "died",
            skin = -1,
            lvl = -1
          })

          lastKilledBy = ""
        end
        while isCharDead(playerPed) do
          wait(1000)
        end
        wait(5000)
      end
    end
  end

  local addKillList = function(killerNick, killedNick, weapon)
    if settings.deathlist.enable then
      if settings.deathlist.hideterra and terra then
        return
      end
      killerId = sampGetPlayerIdByNickname(killerNick)
      killedId = sampGetPlayerIdByNickname(killedNick)
      if killerId ~= nil and killedId ~= nil then
        bs = raknetNewBitStream()
        raknetBitStreamWriteInt16(bs, killerId)
        raknetBitStreamWriteInt16(bs, killedId)
        raknetBitStreamWriteInt8(bs, weapon)
        raknetEmulRpcReceiveBitStream(55, bs)
        raknetDeleteBitStream(bs)
      else
        if killerNick == nil then
          if killedId ~= nil then
            bs = raknetNewBitStream()
            raknetBitStreamWriteInt16(bs, -1)
            raknetBitStreamWriteInt16(bs, killedId)
            raknetBitStreamWriteInt8(bs, 255)
            raknetEmulRpcReceiveBitStream(55, bs)
            raknetDeleteBitStream(bs)
          end
        end
      end
    end
  end

  local checkIfAfkKill = function(name)
    res, killerId = sampGetPlayerIdByCharHandle(PLAYER_PED)

    if res then
      killedId = sampGetPlayerIdByNickname(name)

      if killedId ~= nil and tpmp == false and not isArenaActive() then
        if sampIsPlayerPaused(killedId) then
          killedBitches[name] = killedBitches[name] - 2

          killerNick = sampGetPlayerNickname(killerId)

          if settings.deathlist.debug then
            sampAddChatMessage("убит в афк " .. name, -1)
          end

          local new = {
            killerNick = killerNick,
            killedNick = name,
            weapon = weap,
            type = "afk",
            skin = -1,
            lvl = -1
          }

          res, char = sampGetCharHandleBySampPlayerId(pID)
          if res then
            new["skin"] = getCharModel(char)
            new["lvl"] = sampGetPlayerScore(pID)
          end

          table.insert(deathListTable, new)
        end
      end
    end
  end

  local getMenu = function()
    return {
      title = "{7ef3fa}* " .. (settings.deathlist.enable and "{00ff66}" or "{ff0000}") .. "DEATHLIST",
      submenu = {
        {
          title = "Информация о модуле",
          onclick = function()
            sampShowDialog(
                    0,
                    "{7ef3fa}/edith v." .. thisScript().version .. ' - информация о модуле {00ff66}"DEATHLIST"',
                    "{00ff66}DEATHLIST{ffffff}\nДобавляет локальный киллист, где пользователи эдита делятся информацией друг с другом.\nВо время капта не добавляет килы, F9 - стандартный хоткей вкл/выкл киллиста.",
                    "Окей"
            )
          end
        },
        {
          title = 'Топ',
          onclick = function()
            os.execute('explorer "' .. ip .. 'top"')
          end
        },
        {
          title = " "
        },
        {
          title = "Включить: " .. tostring(settings.deathlist.enable),
          onclick = function()
            settings.deathlist.enable = not settings.deathlist.enable
            inicfg.save(settings, "edith")
          end
        },
        {
          title = "Не добавлять во время терры: " .. tostring(settings.deathlist.hideterra),
          onclick = function()
            settings.deathlist.hideterra = not settings.deathlist.hideterra
            inicfg.save(settings, "edith")
          end
        },
        {
          title = "Дебаг: " .. tostring(settings.deathlist.debug),
          onclick = function()
            settings.deathlist.debug = not settings.deathlist.debug
            inicfg.save(settings, "edith")
          end
        },
        {
          title = "Худ: " .. tostring(settings.deathlist.hud),
          onclick = function()
            settings.deathlist.hud = not settings.deathlist.hud
            inicfg.save(settings, "edith")
          end
        },
      }
    }
  end

  local description = function()
    return "{7ef3fa}* " .. (settings.deathlist.enable and "{00ff66}" or "{ff0000}") .. "DEATHLIST - {ffffff}Локальный киллист и онлайн-топ по убийстам, смертям, урона и деморгану."
  end

  local enableAll = function()
    settings.deathlist.enable = true
    settings.deathlist.debug = false
    settings.deathlist.hud = true
  end

  local disableAll = function()
    settings.deathlist.enable = false
    settings.deathlist.debug = false
    settings.deathlist.hud = false
  end

  local defaults = {
    enable = true,
    debug = false,
    hud = true,
    prikol = true,
    hideterra = false
  }

  local onCreate3DText = function(id, color, position, distance, testLOS, attachedPlayerId, attachedVehicleId, text)
    if distance == 100 and (color == -1 or color == -16776961) and testLOS and attachedPlayerId == 65535 and attachedVehicleId == 65535 then
      if tpmp == false and not isArenaActive() then
        damage_col = damage_col + tonumber(text)
      end
    end
  end

  local setContains = function(set, key)
    return set[key] ~= nil
  end

  local onPlayerDeath = function(pID)
    if sampIsPlayerConnected(pID) then
      local name = sampGetPlayerNickname(pID)
      if setContains(killedBitches, name) and setContains(woundedBitches, name) then
        if settings.deathlist.debug then
          print('killedBitches & woundedBitches checked')
        end
        local time1 = os.time(os.date("!*t")) - killedBitches[name]
        local time2 = os.time(os.date("!*t")) - woundedBitches[name]
        if settings.deathlist.debug then
          print("Разница", time1, time2)
        end
        if time1 < 4 and time2 < 4 then
          if settings.deathlist.debug then
            print("УСЛОВИЕ УДОБЛЕТВОРЕНО")
          end
          local res, killerId = sampGetPlayerIdByCharHandle(PLAYER_PED)
          if res and tpmp == false and not isArenaActive() then
            local killerNick = sampGetPlayerNickname(killerId)

            if settings.deathlist.debug then
              sampAddChatMessage("Убит " .. name, -1)
            end

            local new = {
              killerNick = killerNick,
              killedNick = name,
              weapon = weap,
              type = "normal",
              skin = -1,
              lvl = -1
            }

            local res, char = sampGetCharHandleBySampPlayerId(pID)
            if res then
              new["skin"] = getCharModel(char)
              new["lvl"] = sampGetPlayerScore(pID)
            end

            table.insert(deathListTable, new)
          end
        end
      end
    end
  end

  local addToSet = function(set, key)
    set[key] = os.time(os.date("!*t"))
  end

  local onShowTextDraw = function(id, tab)
    if id and tab then
      if tab.text:find("~y~KILLS~n~") then
        terra = true
        terra_id = id
      end
      if tab.flags == 18 then
        if string.find(tab.text, "KILL") ~= nil then
          name = string.match(string.gsub(tab.text, ' %- KILL', ''), '(.+) %-')
          if setContains(killedBitches, name) then
            local time = os.time(os.date("!*t")) - killedBitches[name]
            if time > 5 then
              if setContains(woundedBitches, name) then
                local time = os.time(os.date("!*t")) - woundedBitches[name]
                if time < 2 then
                  addToSet(killedBitches, name)
                  checkIfAfkKill(name)
                end
              end
            end
          else
            addToSet(killedBitches, name)
            checkIfAfkKill(name)
          end
        end
      end
      if tab.flags == 24 then
        if string.find(tab.text, "KILL") ~= nil then
          name = string.match(string.gsub(tab.text, '%-%d[%d.,]* %- KILL', ''), '(.+) %-')
          lastKilledBy = name
        end
      end
    end
  end

  local onTextDrawHide = function(id)
    if terra and terra_id ~= 0 then
      if terra_id == id then
        terra = false
        terra_id = 0
      end
    end
  end

  local onSendGiveDamage = function(playerID, damage, weaponID, bodypart)
    if sampIsPlayerConnected(playerID) then
      weap = weaponID
      addToSet(woundedBitches, sampGetPlayerNickname(playerID))
    end
  end

  local onSendTakeDamage = function(playerID, damage, weaponID, bodypart)
    if sampIsPlayerConnected(playerID) then
      if playerID < 1001 then
        enemyWeap = weaponID
        if tpmp == false and not isArenaActive() then
          damage_col_in = damage_col_in + damage
        end
      end
    end
  end

  local onServerMessage = function(color, text)
    if text == " Вы телепортированы. Для выхода используйте /tpmp" then
      tpmp = true
    end

    if string.find(text, "Администратор (.+) посадил вас на (%d+) минут. Причина: (.+)") then
      local adm, min, reason = string.match(text, "Администратор (.+) посадил вас на (%d+) минут. Причина: (.+)")
      res, killedId = sampGetPlayerIdByCharHandle(PLAYER_PED)
      if res then
        killedNick = sampGetPlayerNickname(killedId)

        table.insert(deathListTable, {
          killerNick = killedNick,
          killedNick = adm,
          weapon = u8:encode(reason),
          type = "dm",
          skin = -1,
          lvl = min
        })
      end
    end
  end

  local onSetPlayerPos = function()
    tpmp = false
  end

  local prepare = function(request_table)
    if os.clock() - deathListTiming > 0.5 then
      request_table["getDeathList"] = 1
      deathListTiming = os.clock()
    end

    if deathListTable ~= {} then
      request_table["deathList"] = deathListTable
      deathListTable = {}
    end

    if os.clock() - dmg_timing > 15 then
      if damage_col ~= 0 then
        request_table["dmg_out"] = damage_col
        damage_col = 0
      end

      if tonumber(damage_col_in) ~= 0 then
        request_table["dmg_in"] = math.floor(damage_col_in)
        damage_col_in = 0
      end

      dmg_timing = os.clock()
    end
  end

  local process = function(ad)
    if deathlist_timestamp == 0 then
      deathlist_timestamp = ad["timestamp"]
    end

    if ad["deathList"] ~= nil then
      for k, v in pairs(ad["deathList"]) do
        if v["time"] > deathlist_timestamp then
          if settings.deathlist.debug then
            sampAddChatMessage(u8:decode(v.text), -1)
            print("РИСУЕМ", k, v.time, v.data.killerNick, v.data.killerNick, v.data.killedNick, v.data.weapon)
          end
          if v.data.type == "dm" then
            deathlist.addKillList(v.data.killedNick, v.data.killerNick, 38)
          else
            if (v.data.type == "normal" or v.data.type == "afk") and v.data.killerNick == licensenick then
              if settings.deathlist.hud then
                if v.score >= 0 then
                  printStringNow("+" .. v.score, 1500)
                else
                  printStringNow("-" .. v.score, 1500)
                end
              end
            end
            deathlist.addKillList(v.data.killerNick, v.data.killedNick, v.data.weapon)
          end
          deathlist_timestamp = v["time"]
        else
          if settings.deathlist.debug then
            print("СКИП", k, v.time, v.data.killerNick, v.data.killerNick, v.data.killedNick, v.data.weapon)
          end
        end
      end
    end
  end

  return {
    main = mainThread,
    addKillList = addKillList,

    getMenu = getMenu,
    desc = description,
    enable = enableAll,
    disable = disableAll,
    defaults = defaults,

    onPlayerDeath = onPlayerDeath,
    onCreate3DText = onCreate3DText,
    onShowTextDraw = onShowTextDraw,
    onSendGiveDamage = onSendGiveDamage,
    onSendTakeDamage = onSendTakeDamage,
    onServerMessage = onServerMessage,
    onSetPlayerPos = onSetPlayerPos,
    onTextDrawHide = onTextDrawHide,

    prepare = prepare,
    process = process
  }
end
--------------------------------------------------------------------------------
--------------------------------------ADR---------------------------------------
--------------------------------------------------------------------------------
function adrModule()
  local lomka = false
  local perelom = false
  local cough = false

  local mainThread = function()
    while true do
      wait(0)
      if settings.adr.enable then
        if lomka then
          sampSendChat("/adr")
          wait(30)
          sampSetSpecialAction(68)
          wait(50)
          sampSetSpecialAction(0)
          lomka = false
        end
        if perelom then
          sampSendChat("/adr")
          wait(30)
          sampSetSpecialAction(68)
          wait(50)
          sampSetSpecialAction(0)
          perelom = false
        end
        if cough then
          sampSetSpecialAction(68)
          wait(50)
          sampSetSpecialAction(0)
          cough = false
        end
      end
    end
  end

  local getMenu = function()
    return {
      title = "{7ef3fa}* " .. (settings.adr.enable and "{00ff66}" or "{ff0000}") .. "ADR {808080}[могут заварнить, а могут и нет]",
      submenu = {
        {
          title = "Информация о модуле",
          onclick = function()
            sampShowDialog(
                    0,
                    "{7ef3fa}/edith v." .. thisScript().version .. ' - информация о модуле {00ff66}"ADR"',
                    "{00ff66}ADR{ffffff}\nАвтоматическое использование адреналина и сбив его.",
                    "Окей"
            )
          end
        },
        {
          title = " "
        },
        {
          title = "Включить: " .. tostring(settings.adr.enable),
          onclick = function()
            settings.adr.enable = not settings.adr.enable
            inicfg.save(settings, "edith")
          end
        },
        {
          title = " "
        },
        {
          title = "Ломка: " .. tostring(settings.adr.lomka),
          onclick = function()
            settings.adr.lomka = not settings.adr.lomka
            inicfg.save(settings, "edith")
          end
        },
        {
          title = "Перелом: " .. tostring(settings.adr.perelom),
          onclick = function()
            settings.adr.perelom = not settings.adr.perelom
            inicfg.save(settings, "edith")
          end
        },
        {
          title = "Кашель: " .. tostring(settings.adr.cough),
          onclick = function()
            settings.adr.cough = not settings.adr.cough
            inicfg.save(settings, "edith")
          end
        },
      }
    }
  end

  local description = function()
    return "{7ef3fa}* " .. (settings.adr.enable and "{00ff66}" or "{ff0000}") .. "ADR [могут заварнить] - {ffffff}Автоматическое использование адреналина при: перелом, ломка. Сбив кашля."
  end

  local enableAll = function()
    settings.adr.enable = true
    settings.adr.lomka = true
    settings.adr.cough = true
    settings.adr.perelom = true
  end

  local disableAll = function()
    settings.adr.enable = false
    settings.adr.lomka = false
    settings.adr.cough = false
    settings.adr.perelom = false
  end

  local defaults = {
    enable = false,
    cough = false,
    lomka = false,
    perelom = false,
  }

  local onServerMessage = function(color, text)
    if settings.adr.enable then
      if string.find(text, "началась ломка") and color == -1627389697 and settings.adr.lomka then
        lomka = true
      end
      if string.find(text, "ноги") or string.find(text, "руки") and settings.adr.perelom then
        if color == -12434689 then
          perelom = true
        end
      end
      if string.find(text, "нога") or string.find(text, "рука") and settings.adr.perelom then
        if color == -12434689 then
          perelom = true
        end
      end
      if string.find(text, "приступ кашля") and color == -12434689 and settings.adr.cough then
        cough = true
      end
    end
  end

  return {
    main = mainThread,
    getMenu = getMenu,
    desc = description,
    enable = enableAll,
    disable = disableAll,
    defaults = defaults,
    onServerMessage = onServerMessage
  }
end

--------------------------------------------------------------------------------
-------------------------------------MARKER-------------------------------------
--------------------------------------------------------------------------------
function markerModule()
  local target = nil
  local remove_target = false
  local mark
  local pick
  local check
  local result
  local cur_x = 0

  local get_crosshair_position = function()
    local vec_out = ffi.new("float[3]")
    local tmp_vec = ffi.new("float[3]")
    ffi.cast(
            "void (__thiscall*)(void*, float, float, float, float, float*, float*)",
            0x514970
    )(
            ffi.cast("void*", 0xB6F028),
            15.0,
            tmp_vec[0], tmp_vec[1], tmp_vec[2],
            tmp_vec,
            vec_out
    )
    return vec_out[0], vec_out[1], vec_out[2]
  end

  local clrMarker = function()
    cur_x = 0
    removeBlip(mark)
    removePickup(pick)
    deleteCheckpoint(check)
  end

  local setMarker = function(x, y, z)
    clrMarker()
    cur_x = x
    result, pick = createPickup(19605, 19, x, y, z)
    check = createCheckpoint(2, x, y, z, x, y, z, 1.5)
    mark = addSpriteBlipForCoord(x, y, z, 56)
    if settings.marker.sound then
      addOneOffSound(0.0, 0.0, 0.0, 1052)
    end
  end

  local setTarget = function(x, y, z)
    target = {
      x = x,
      y = y,
      z = z
    }
    clrMarker()
    setMarker(x, y, z)
  end

  local mainThread = function()
    while true do
      wait(0)
      if settings.marker.enable then
        if isKeyDown(2) and isKeyJustPressed(settings.marker.keyDel) then
          remove_target = true
          clrMarker()
        end
        if isKeyDown(2) and isKeyJustPressed(settings.marker.key1) then
          local sx, sy = convert3DCoordsToScreen(get_crosshair_position())
          local posX, posY, posZ = convertScreenCoordsToWorld3D(sx, sy, 700.0)
          local camX, camY, camZ = getActiveCameraCoordinates()
          local result, colpoint = processLineOfSight(camX, camY, camZ, posX, posY, posZ, true, true, false, true, false, false, false)
          if result and colpoint.entity ~= 0 then
            local normal = colpoint.normal
            local pos = Vector3D(colpoint.pos[1], colpoint.pos[2], colpoint.pos[3]) - (Vector3D(normal[1], normal[2], normal[3]) * 0.1)

            setTarget(pos.x, pos.y, pos.z)
          end
        end
      end
    end
  end

  local changemarkerhotkey = function(mode)
    sampShowDialog(
            989,
            "Изменение горячей клавиши активации marker или деактивации",
            'Нажмите "Окей", после чего нажмите нужную клавишу.\nНастройки будут изменены.',
            "Окей",
            "Закрыть"
    )
    while sampIsDialogActive(989) do
      wait(100)
    end
    local resultMain, buttonMain, typ = sampHasDialogRespond(989)
    if buttonMain == 1 then
      while ke1y == nil do
        wait(0)
        for i = 1, 200 do
          if isKeyDown(i) then
            if mode == 1 then
              settings.marker.key1 = i
            elseif mode == 2 then
              settings.marker.keyDel = i
            end
            sampAddChatMessage("Установлена новая горячая клавиша - " .. key.id_to_name(i), -1)
            addOneOffSound(0.0, 0.0, 0.0, 1052)
            inicfg.save(settings, "edith")
            ke1y = 1
            break
          end
        end
      end
      ke1y = nil
    end
  end

  local getMenu = function()
    return {
      title = "{7ef3fa}* " .. (settings.marker.enable and "{00ff66}" or "{ff0000}") .. "MARKER {808080}[ALFA]",
      submenu = {
        {
          title = "Информация о модуле",
          onclick = function()
            sampShowDialog(
                    0,
                    "{7ef3fa}/edith v." .. thisScript().version .. ' - информация о модуле {00ff66}"MARKER"',
                    "{00ff66}MARKER{ffffff}\nОтправляет клиентам сервера информацию о метке по прицелу + {7ef3fa}" .. tostring(key.id_to_name(settings.marker.key1)) .. "{ffffff}.\nПрицел + {7ef3fa}" .. tostring(key.id_to_name(settings.marker.keyDel)) .. "{ffffff} - убрать метку.\nМетка только одна на сервер, пропадает через 30 секунд.\nМожно настроить звук когда она обновляется.",
                    "Окей"
            )
          end
        },
        {
          title = " "
        },
        {
          title = "Включить: " .. tostring(settings.marker.enable),
          onclick = function()
            settings.marker.enable = not settings.marker.enable
            if settings.marker.enable == false then
              clrMarker()
            end
            inicfg.save(settings, "edith")
          end
        },
        {
          title = " "
        },
        {
          title = "Звук: " .. tostring(settings.marker.sound),
          onclick = function()
            settings.marker.sound = not settings.marker.sound
            inicfg.save(settings, "edith")
          end
        },
        {
          title = "Изменить горячую клавишу активации",
          onclick = function()
            table.insert(tempThreads, lua_thread.create(changemarkerhotkey, 1))
          end
        },
        {
          title = "Изменить горячую клавишу деактивации",
          onclick = function()
            table.insert(tempThreads, lua_thread.create(changemarkerhotkey, 2))
          end
        },
      }
    }
  end

  local description = function()
    return "{7ef3fa}* " .. (settings.marker.enable and "{00ff66}" or "{ff0000}") .. "MARKER - {ffffff}Отправляет клиентам сервера информацию о метке по прицелу + {7ef3fa}" .. tostring(key.id_to_name(settings.marker.key1)) .. "{ffffff}. Прицел + {7ef3fa}" .. tostring(key.id_to_name(settings.marker.keyDel)) .. " - убрать."
  end

  local enableAll = function()
    settings.marker.enable = true
  end

  local disableAll = function()
    settings.marker.enable = false
  end

  local defaults = {
    enable = true,
    key1 = VK_3,
    keyDel = VK_4,
    sound = true
  }

  local prepare = function(request_table)
    if settings.marker.enable then
      if target ~= nil then
        request_table["marker"] = target

        target = nil
      elseif remove_target then
        request_table["marker_remove"] = true

        remove_target = false
      end
    end
  end

  local process = function(ad)
    if settings.marker.enable then
      if ad["marker"] then
        if math.ceil(cur_x) ~= math.ceil(ad.marker.data.x) and target == nil then
          setMarker(ad.marker.data.x, ad.marker.data.y, ad.marker.data.z)
        end
      else
        clrMarker()
      end
    end
  end

  local onScriptTerminate = function()
    if settings and settings.marker and settings.marker.enable then
      clrMarker()
    end
  end

  return {
    main = mainThread,
    getMenu = getMenu,
    desc = description,
    enable = enableAll,
    disable = disableAll,
    defaults = defaults,

    prepare = prepare,
    process = process,

    onScriptTerminate = onScriptTerminate
  }
end
--------------------------------------------------------------------------------
----------------------------------GANGHELPER------------------------------------
--------------------------------------------------------------------------------
function ganghelperModule()
  local coord_resp = {
    { 2494.29296875, -1681.8502197266, 12.338387489319 }, -- grove
    { 2183.3081054688, -1807.8851318359, 12.373405456543 }, -- rifa
    { 287.72546386719, -141.66345214844, 1006.15625 }, -- rifa inta
    { 1582.6881103516, -1597.0266113281, 27.475524902344 }, -- aztec inta
    { 1672.9483642578, -2113.423828125, 12.546875 }, -- aztec
    { 2647.3308105469, -2029.4759521484, 12.546875 }, -- ballas
    { 607.73522949219, -147.71377563477, 0 }, -- ballas inta
    { 2780.3444824219, -1615.7406005859, 9.921875 }, -- vagos
    { 358.85055541992, 34.617668151855, 0 } -- vagos inta
  }
  local skin = { 41, 114, 115, 116, 56, 105, 106, 107, 269, 270, 271, 195, 102, 103, 104, 190, 108, 109, 110, 226, 173, 174, 175 }
  local sleep = 0
  local result = 0
  local dist = 99999
  local checkafk = os.time()
  local fcapture = false

  local antiFlood = function()
    repeat
      wait(100)
      local res, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
      local ms = math.ceil(os.clock() * 1000 - sleep)
    until ms > 600 and sampGetPlayerScore(id) >= 1 and not sampIsDialogActive() and not sampIsChatInputActive()
  end

  local isBandit = function()
    result = false
    for i = 1, #skin do
      if isCharModel(PLAYER_PED, skin[i]) then
        result = true
      end
    end
    return result
  end

  local mainThread = function()
    if settings.ganghelper.fcapture then
      sampRegisterChatCommand("fcapture", function()
        fcapture = not fcapture
      end)
    end
    while true do
      wait(0)
      if settings.ganghelper.enable then
        if settings.ganghelper.fcapture and fcapture then
          antiFlood()
          sampSendChat("/capture")
        end
        checkafk = os.clock()
        if settings.ganghelper.gunkeys then
          if not sampIsChatInputActive() and not isSampfuncsConsoleActive() and not sampIsDialogActive() then
            if isKeyDown(settings.ganghelper.keyDeagle) and isBandit() then
              antiFlood()
              sampSendChat("/gun deagle 14")
            end
            if isKeyDown(settings.ganghelper.keyM4) and isBandit() then
              antiFlood()
              sampSendChat("/gun m4 20")
            end
            if isKeyDown(settings.ganghelper.keyRifle) and isBandit() then
              antiFlood()
              sampSendChat("/gun rifle 10")
            end
          end
        end
      end
    end
  end

  local getMenu = function()
    return {
      title = "{7ef3fa}* " .. (settings.ganghelper.enable and "{00ff66}" or "{ff0000}") .. "GANGHELPER",
      submenu = {
        {
          title = "Информация о модуле",
          onclick = function()
            sampShowDialog(
                    0,
                    "{7ef3fa}/edith v." .. thisScript().version .. ' - информация о модуле {00ff66}"GANGHELPER"',
                    "{00ff66}GANGHELPER{ffffff}\nФункции, упрощающие геймплей бандита\n\n1. Автопополнение материалов когда вы на респе и склад открывается.\n2. Хоткеи на оружие: 4 - deagle 14, 5 - m4 20, 6 - rifle 10.",
                    "Окей"
            )
          end
        },
        {
          title = " "
        },
        {
          title = "Включить: " .. tostring(settings.ganghelper.enable),
          onclick = function()
            settings.ganghelper.enable = not settings.ganghelper.enable
            inicfg.save(settings, "edith")
          end
        },
        {
          title = " "
        },
        {
          title = "Брать ган когда открывается склад: " .. tostring(settings.ganghelper.getguns),
          onclick = function()
            settings.ganghelper.getguns = not settings.ganghelper.getguns
            inicfg.save(settings, "edith")
          end
        },
        {
          title = "Хоткеи на оружие: " .. tostring(settings.ganghelper.gunkeys),
          onclick = function()
            settings.ganghelper.gunkeys = not settings.ganghelper.gunkeys
            inicfg.save(settings, "edith")
          end
        },
        {
          title = "Флудер /fcapture: " .. tostring(settings.ganghelper.fcapture),
          onclick = function()
            settings.ganghelper.fcapture = not settings.ganghelper.fcapture
            inicfg.save(settings, "edith")
            thisScript():reload()
          end
        }
      }
    }
  end

  local description = function()
    return "{7ef3fa}* " .. (settings.ganghelper.enable and "{00ff66}" or "{ff0000}") .. "GANGHELPER - {ffffff}Упрощение геймплея бандита."
  end

  local enableAll = function()
    settings.ganghelper.enable = true
  end

  local disableAll = function()
    settings.ganghelper.enable = false
  end

  local defaults = {
    enable = true,
    getguns = true,
    gunkeys = false,
    fcapture = true,
    keyDeagle = VK_4,
    keyM4 = VK_5,
    keyRifle = VK_6
  }

  local onServerMessage = function(color, text)
    if settings.ganghelper.enable then
      if settings.ganghelper.fcapture then
        if text == " Ваша банда уже воюет за территорию" then
          fcapture = false
        end
      end
      if settings.ganghelper.getguns then
        if string.find(text, " (.*) открыл%(а%) склад с оружием") then
          if not (os.clock() - checkafk > 5) and isBandit() then
            for k, v in pairs(coord_resp) do
              dist = math.floor(getDistanceBetweenCoords3d(v[1], v[2], v[3], getCharCoordinates(playerPed)))
              if dist <= 100.0 then
                table.insert(tempThreads, lua_thread.create(function()
                  antiFlood()
                  sampSendChat('/get guns')
                end))
                break
              end
            end
          end
        end
      end
    end
  end

  local onSendChat = function(message)
    sleep = os.clock() * 1000
  end

  local onSendCommand = function(cmd)
    sleep = os.clock() * 1000
  end

  return {
    main = mainThread,
    getMenu = getMenu,
    desc = description,
    enable = enableAll,
    disable = disableAll,
    defaults = defaults,
    onServerMessage = onServerMessage,
    onSendChat = onSendChat,
    onSendCommand = onSendCommand
  }
end
--------------------------------------------------------------------------------
-----------------------------------BIKER-INFO-----------------------------------
--------------------------------------------------------------------------------
function bikerInfoModule()
  local warehouse_simple
  local warehouse
  local capture
  local next

  local Set = function(list)
    local set = {}
    for _, l in ipairs(list) do
      set[l] = true
    end
    return set
  end

  local skins_bikers = Set { 247, 248, 254, 100, 181, 178, 246 }

  local getMenu = function()
    return {
      title = "{7ef3fa}* " .. (settings.bikerinfo.enable and "{00ff66}" or "{ff0000}") .. "BIKERINFO",
      submenu = {
        {
          title = "Информация о модуле",
          onclick = function()
            sampShowDialog(
                    0,
                    "{7ef3fa}/edith v." .. thisScript().version .. ' - информация о модуле {00ff66}"BIKERINFO"',
                    "{00ff66}BIKERINFO{ffffff}\nОтправляет на сервер информацию о складе и /capture.",
                    "Окей"
            )
          end
        },
        {
          title = " "
        },
        {
          title = "Включить: " .. tostring(settings.bikerinfo.enable),
          onclick = function()
            settings.bikerinfo.enable = not settings.bikerinfo.enable
            inicfg.save(settings, "edith")
          end
        },
        {
          title = " "
        },
        {
          title = "Отправлять информацию о складе: " .. tostring(settings.bikerinfo.warehouse),
          onclick = function()
            settings.bikerinfo.warehouse = not settings.bikerinfo.warehouse
            inicfg.save(settings, "edith")
          end
        },
        {
          title = "Отправлять информацию о бизнесах: " .. tostring(settings.bikerinfo.bizlist),
          onclick = function()
            settings.bikerinfo.bizlist = not settings.bikerinfo.bizlist
            inicfg.save(settings, "edith")
          end
        },
      }
    }
  end

  local description = function()
    return "{7ef3fa}* " .. (settings.bikerinfo.enable and "{00ff66}" or "{ff0000}") .. "BIKERINFO - {ffffff}Отправляет на сервер информацию о складе и /capture."
  end

  local enableAll = function()
    settings.bikerinfo.enable = true
    settings.bikerinfo.warehouse = true
    settings.bikerinfo.bizlist = true
  end

  local disableAll = function()
    settings.bikerinfo.enable = false
    settings.bikerinfo.warehouse = false
    settings.bikerinfo.bizlist = false
  end

  local defaults = {
    enable = true,
    warehouse = true,
    bizlist = true,
  }

  local prepare = function(request_table)
    request_table["bikerinfo"] = {}
    if warehouse_simple ~= nil then
      request_table["bikerinfo"]["warehouse_simple"] = warehouse_simple
      warehouse_simple = nil
    end

    if warehouse ~= nil then
      request_table["bikerinfo"]["warehouse"] = warehouse
      warehouse = nil
    end

    if capture ~= nil then
      request_table["bikerinfo"]["capture"] = capture
      capture = nil
    end

    if next ~= nil then
      request_table["bikerinfo"]["capture_next"] = next
      next = nil
    end
  end

  local onServerMessage = function(color, text)
    if settings.bikerinfo.enable then
      if settings.bikerinfo.bizlist then
        if color == -1347440641 then
          local nextH, nextM = string.match(text, " В данный момент начать войну не получится. Попробуйте повторить примерно через (%d+)%:(%d+)")
          if nextH and nextM then
            nextM = tonumber(nextM) + tonumber(nextH) * 60
            next = {
              timestamp = os.time(),
              next = nextM * 60
            }
          end
        end
      end

      if settings.bikerinfo.warehouse then
        local skin = getCharModel(playerPed)
        if skin and skins_bikers[skin] then
          if color == 1687547391 then
            local wh = string.match(text, " На складе осталось (%d+) материалов")
            if wh then
              warehouse_simple = {
                timestamp = os.time(),
                wh = wh
              }
            end

            local wh, wh_all, heal, heal_all, alk, alk_all, benz, benz_all = string.match(text, " (%d+)/(%d+) Матов | (%d+)/(%d+) Аптечек | (%d+)/(%d+) Алкоголя | (%d+)/(%d+) Бензина")
            if wh_all then
              warehouse = {
                timestamp = os.time(),
                data = {
                  wh = wh,
                  wh_all = wh_all,
                  heal = heal,
                  heal_all = heal_all,
                  alk = alk,
                  alk_all = alk_all,
                  benz = benz,
                  benz_all = benz_all
                }
              }
            end
          end
        end
      end
    end
  end

  local getBizType = function(color)
    if color == "C42100" then
      return "r"
    else
      return "w"
    end
  end

  local onShowDialog = function(dialog, style, title, button1, button2, text)
    if settings.bikerinfo.enable then
      if settings.bikerinfo.bizlist then
        local skin = getCharModel(playerPed)
        if skin and skins_bikers[skin] then
          if button1 == "Атаковать" and title == "Выберите объект" then
            local s1, b1, s2, b2, s3, b3, s4, b4, s5, b5, s6, b6, s7, b7, s8, b8 = string.match(text, "{(.+)}Ферма №0 %[(.+)%]\n{(.+)}Ферма №1 %[(.+)%]\n{(.+)}Ферма №2 %[(.+)%]\n{(.+)}Ферма №3 %[(.+)%]\n{(.+)}Ферма №4 %[(.+)%]\n{(.+)}Мастерская №0 %[(.+)%]\n{(.+)}Мастерская №1 %[(.+)%]\n{(.+)}Мастерская №2 %[(.+)%]")
            if s1 then
              capture = {
                timestamp = os.time(),
                data = {
                  f0 = {
                    type = getBizType(s1),
                    control = b1:gsub("’", "")
                  },
                  f1 = {
                    type = getBizType(s2),
                    control = b2:gsub("’", "")
                  },
                  f2 = {
                    type = getBizType(s3),
                    control = b3:gsub("’", "")
                  },
                  f3 = {
                    type = getBizType(s4),
                    control = b4:gsub("’", "")
                  },
                  f4 = {
                    type = getBizType(s5),
                    control = b5:gsub("’", "")
                  },
                  s0 = {
                    type = getBizType(s6),
                    control = b6:gsub("’", "")
                  },
                  s1 = {
                    type = getBizType(s7),
                    control = b7:gsub("’", "")
                  },
                  s2 = {
                    type = getBizType(s8),
                    control = b8:gsub("’", "")
                  },
                }
              }
            end
          end
        end
      end
    end
  end

  return {
    getMenu = getMenu,
    desc = description,
    enable = enableAll,
    disable = disableAll,
    defaults = defaults,

    prepare = prepare,

    onServerMessage = onServerMessage,
    onShowDialog = onShowDialog
  }
end
--------------------------------------------------------------------------------
------------------------------------TEMPLATE------------------------------------
--------------------------------------------------------------------------------
function checkerModule()
  local myname, font, checker_update, ini, achecker, afkchecker, setpos, _, id, activeCheck

  local stopCheck = false
  local checkerAfkBase = 0
  local lastSyncAfk = 0
  local justGotParsed = false
  local adminsCheckerSend = {}
  local admins = {
    timestamp = 0,
    data = {}
  }

  local sleep = 0

  local antiFlood = function()
    repeat
      wait(100)
      local res, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
      local ms = math.ceil(os.clock() * 1000 - sleep)
    until ms > 1200 and sampGetPlayerScore(id) >= 1 and not sampIsDialogActive() and not sampIsChatInputActive()
  end

  local disp_time = function(time)
    local remaining = time
    local hours = math.floor(remaining / 3600)
    remaining = remaining % 3600
    local minutes = math.floor(remaining / 60)
    remaining = remaining % 60
    local seconds = remaining
    if (hours < 10) then
      hours = "0" .. tostring(hours)
    end
    if (minutes < 10) then
      minutes = "0" .. tostring(minutes)
    end
    if (seconds < 10) then
      seconds = "0" .. tostring(seconds)
    end
    local answer = hours .. ':' .. minutes .. ':' .. seconds
    return answer
  end

  local showAdminsList = function()
    local count = 0
    local dialogText = "Имя[ID]\tАдмин уровень\tИгровой уровень\n"
    for i = 0, sampGetMaxPlayerId(false) do
      if sampIsPlayerConnected(i) then
        local name = sampGetPlayerNickname(i)
        local score = sampGetPlayerScore(i)
        local color = sampGetPlayerColor(i)
        color = string.format("%X", tonumber(color))
        if #color == 8 then
          _, color = string.match(color, "(..)(......)")
        end
        if ini ~= nil and ini.admins[name] ~= nil then
          local server, lvl = string.match(ini.admins[name], "(.+) (%d+)")
          local text = ""
          if server and lvl then
            if admins.data[name] ~= nil and admins.data[name]["afk"] ~= 0 and i == admins.data[name]["id"] then
              dialogText = string.format('%s{%s}%s{FFFFFF} [%d] {ff0000}AFK [%d]\t%s-%d\t%d\n', dialogText, color, name, i, admins.data[name]["afk"], string.sub(server, 1, 4), lvl, score)
			elseif admins.data[name] == nil then
              dialogText = string.format('%s{%s}%s{FFFFFF} [%d]\t%s-%d [нет в /admins]\t%d\n', dialogText, color, name, i, string.sub(server, 1, 4), lvl, score)
			else
              dialogText = string.format('%s{%s}%s{FFFFFF} [%d]\t%s-%d\t%d\n', dialogText, color, name, i, string.sub(server, 1, 4), lvl, score)
            end
            count = count + 1
          end
        end
      end
    end
    sampShowDialog(0, "Админов в сети: " .. count .. ". Данные /admins устарели на: " .. disp_time(os.time() - admins.timestamp), dialogText, "Закрыть", "", 5)
  end

  local download_admins = function()
    local response_path = os.tmpname()
    downloadUrlToFile(ip .. "parse_admins", response_path, function(id, status, p1, p2)
      if status == dlstatus.STATUS_ENDDOWNLOADDATA then
        local f = io.open(response_path, "r")
        if f then
          local text = f:read("*a")
          if text ~= nil then
            local json = decodeJson(text)
            if json["result"] == "ok" then
              local data = json["data"]
              local new_data = {}
              table.insert(data,
                      {
                        lvl = 99,
                        name = "Don_Elino",
                        server = "staff"
                      }
              )
              table.insert(data,
                      {
                        lvl = 99,
                        name = "Meow_Alferov",
                        server = "staff"
                      }
              )
              for k, v in pairs(data) do
                new_data[v.name] = string.format("%s %s", v.server, v.lvl)
              end
              ini["admins"] = new_data
              ini.Settings.Upd = json["update"]
              inicfg.save(ini, "edith-checker")
			  justGotParsed = true
            end
          end
          io.close(f)
          os.remove(response_path)
        end
      end
    end)
  end

  local mainThread = function()
    if not isSampLoaded() or not isSampfuncsLoaded() then
      return
    end
    while not isSampAvailable() do
      wait(0)
    end
    if settings.checker.enable then
      _, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
      myname = sampGetPlayerNickname(id)
      ini = inicfg.load({
        Settings = {
          FontName = 'Segoe UI',
          FontSize = 10,
          FontFlag = 13,
          X = 153,
          Y = 634,
          Upd = 0
        },
        [myname] = {
          render = false
        },
        admins = {
          ["Flazy_Fad"] = "head 10"
        }
      }, "edith-checker")
      inicfg.save(ini, "edith-checker")
      font = renderCreateFont(ini.Settings.FontName, ini.Settings.FontSize, ini.Settings.FontFlag)
      checker_update = 0

      local last_upd = 0
      local render_table = {}
      local count = 0

      while true do
        wait(0)

        if setpos then
          sampSetCursorMode(2)
          ini.Settings.X, ini.Settings.Y = getCursorPos()
          if wasKeyPressed(1) then
            setpos = nil
            inicfg.save(ini, "edith-checker")
            sampSetCursorMode(0)
          end
        end

        if ini[myname].render then
          if os.clock() - last_upd > 1 then
            render_table = {}
            count = 0
            for i = 0, sampGetMaxPlayerId(false) do
              if sampIsPlayerConnected(i) then
                local name = sampGetPlayerNickname(i)
                local stream, ped = sampGetCharHandleBySampPlayerId(i)
                local score = sampGetPlayerScore(i)
                local color = sampGetPlayerColor(i)

                color = string.format("%X", tonumber(color))
                if #color == 8 then
                  _, color = string.match(color, "(..)(......)")
                end
                if ini ~= nil and ini.admins[name] ~= nil then
                  local server, lvl = string.match(ini.admins[name], "(.+) (%d+)")
                  local text = ""
                  if server and lvl then
                    if admins.data[name] ~= nil and admins.data[name]["afk"] ~= 0 and i == admins.data[name]["id"] then
                      text = string.format(' {%s}%s{FFFFFF}[%d] {ff0000}[LVL: %s-%d] [Score: %d] [AFK: %d] %s', color, name, i, string.sub(server, 1, 4), lvl, score, admins.data[name]["afk"], (stream and '(Рядом)' or ''))
                    elseif admins.data[name] == nil then
					    text = string.format(' {%s}%s{FFFFFF}[%d] [LVL: %s-%d] [Score: %d] [Нет в /admins] %s', color, name, i, string.sub(server, 1, 4), lvl, score, (stream and '(Рядом)' or ''))
					else
                      text = string.format(' {%s}%s{FFFFFF}[%d] [LVL: %s-%d] [Score: %d] %s', color, name, i, string.sub(server, 1, 4), lvl, score, (stream and '(Рядом)' or ''))
                    end
                    table.insert(render_table, text)
                    count = count + 1
                  end
                end
              end
            end
            last_upd = os.clock()
          end

          local x, y = ini.Settings.X, ini.Settings.Y + renderGetFontDrawHeight(font)
          y = y + renderGetFontDrawHeight(font)

          for k, v in pairs(render_table) do
            y = y + renderGetFontDrawHeight(font)
            renderFontDrawText(font, v, x, y, -1)
          end

          renderFontDrawText(font, 'Админов в сети (в списке нет /youtubers): ' .. count, ini.Settings.X, ini.Settings.Y, -1)
          renderFontDrawText(font, "Список получен в " .. os.date("%Y-%m-%d %X", ini.Settings.Upd), ini.Settings.X, ini.Settings.Y + renderGetFontDrawHeight(font), -1)
          renderFontDrawText(font, "Данные /admins устарели на: " .. disp_time(os.time() - admins.timestamp), ini.Settings.X, ini.Settings.Y + renderGetFontDrawHeight(font) * 2, -1)
        end
      end
    end
  end

  local updator = function()
    if not isSampLoaded() or not isSampfuncsLoaded() then
      return
    end
    while not isSampAvailable() do
      wait(0)
    end
    while true do
      wait(1000)
      if settings.checker.enable and settings.checker.check then
        if not stopCheck then
          if afkchecker == nil or os.time() - afkchecker > 60 then
            afkchecker = os.time()
            adminsCheckerSend = {}
            activeCheck = true
            antiFlood()
            sampSendChat("/admins")
            wait(1000)
            activeCheck = false
          end
        end
        if achecker == nil or os.time() - achecker > 3600 then
          achecker = os.time()
          pcall(download_admins)
        end
      end
    end
  end

  local getMenu = function()
    return {
      title = "{7ef3fa}* " .. (settings.checker.enable and "{00ff66}" or "{ff0000}") .. "CHECKER",
      submenu = {
        {
          title = "Информация о модуле",
          onclick = function()
            sampShowDialog(
                    0,
                    "{7ef3fa}/edith v." .. thisScript().version .. ' - информация о модуле {00ff66}"CHECKER"',
                    "{00ff66}CHECKER{ffffff}\nЧекер админов рубина, список берется с форума срп.\nЕсли перестанет работать, его будут фиксить люди, которые его написали.\n\n1. /admins list - диалог с админами\n2. /admins pos - сменить позицию рендера\n3. /admins checker - вкл/выкл рендера.",
                    "Окей"
            )
          end
        },
        {
          title = " "
        },
        {
          title = "Включить: " .. tostring(settings.checker.enable),
          onclick = function()
            settings.checker.enable = not settings.checker.enable
            inicfg.save(settings, "edith")
            thisScript():reload()
          end
        },
        {
          title = "Включить парсинг /admins: " .. tostring(settings.checker.check),
          onclick = function()
            settings.checker.check = not settings.checker.check
            inicfg.save(settings, "edith")
            thisScript():reload()
          end
        }
      }
    }
  end

  local description = function()
    return "{7ef3fa}* " .. (settings.checker.enable and "{00ff66}" or "{ff0000}") .. "CHECKER - {ffffff}Чекер админов, данные берутся с форума срп."
  end

  local enableAll = function()
    settings.checker.enable = true
  end

  local disableAll = function()
    settings.checker.enable = false
  end

  local defaults = {
    enable = true,
    check = true,
  }

  local prepare = function(request_table)
    if settings.checker.enable then
      if not stopCheck then
        if checkerAfkBase and activeCheck == false and os.clock() - checkerAfkBase > 1 then
          checkerAfkBase = nil
          local lengthNum = 0
          for k, v in pairs(adminsCheckerSend) do
            lengthNum = lengthNum + 1
          end
          if lengthNum > 0 then
            --update local
            admins = {
              timestamp = os.time(),
              data = adminsCheckerSend
            }
            --send to the server
            request_table["admins"] = {
              timestamp = os.time(),
              data = adminsCheckerSend
            }
          end
        end
      end
      if os.clock() - lastSyncAfk > 10 or justGotParsed then
        request_table["requestAdminsAfk"] = true
        lastSyncAfk = os.clock()
		justGotParsed = false
      end
    end
  end

  local process = function(ad)
    if settings.checker.enable then
      if ad["admins"] ~= nil then
		for k, v in pairs(ad["admins"]["data"]) do
			if ini.admins[k] == nil then
			  ini.admins[k] = string.format("%s %s", "/admins", v.lvl)
			end
		end
        admins = ad["admins"]
      end
    end
  end

  local onSendCommand = function(cmd)
    if settings.checker.enable then
      local command, params = string.match(cmd, "^%/([^ ]*)(.*)")
      if command ~= nil and params ~= nil and command:lower() == "admins" then
        if params:lower() == " pos" then
          setpos = true
          return false
        end
        if params:lower() == " checker" then
          ini[myname].render = not ini[myname].render
          inicfg.save(ini)
          return false
        end
        if params:lower() == " list" then
          showAdminsList()
          return false
        end
      else
        sleep = os.clock() * 1000
      end
    end
  end

  local onServerMessage = function(color, text)
    if settings.checker.enable then
      if activeCheck then
        if text == " Доступно администрации / VIP 2 уровня / саппортам / лидерам" then
          stopCheck = true
          activeCheck = false
          return false
        elseif text then
          if text == " Админы Online:" then
            checkerAfkBase = os.clock()
            return false
          end
          local nick, id, lvl = text:match("% (.+)%[ID: (%d+)%]  %[lvl: (%d+)%]")
          if nick and id and lvl then
            local afk = text:match("%[AFK: (%d+)%]")
            if afk == nil then
              afk = 0
            end
            adminsCheckerSend[nick] = {
              id = tonumber(id),
              lvl = tonumber(lvl),
              afk = tonumber(afk)
            }
            return false
          end
        end
      end
    end
  end

  local onSendChat = function(message)
    sleep = os.clock() * 1000
  end

  return {
    main = mainThread,
    updator = updator,
    getMenu = getMenu,
    desc = description,
    enable = enableAll,
    disable = disableAll,
    defaults = defaults,

    prepare = prepare,
    process = process,

    onSendCommand = onSendCommand,
    onSendChat = onSendChat,
    onServerMessage = onServerMessage
  }
end
--------------------------------------------------------------------------------
-------------------------------------OFFICE-------------------------------------
--------------------------------------------------------------------------------
function officeGetgunModule()
  ogg = false
  oggtable = {}

  local mainThread = function()
    while true do
      wait(100)
      ogg = false
      while settings.officegetgun.enable and getActiveInterior() ~= 11 do
        wait(100)
        if
        wasKeyPressed(settings.officegetgun.key) and sampIsChatInputActive() == false and
            isSampfuncsConsoleActive() == false and
            sampIsDialogActive() == false
        then
          oggtable["sdpistol"] = settings.officegetgun.sdpistol
          oggtable["deagle"] = settings.officegetgun.deagle
          oggtable["shotgun"] = settings.officegetgun.shotgun
          oggtable["smg"] = settings.officegetgun.smg
          oggtable["ak47"] = settings.officegetgun.ak47
          oggtable["m4a1"] = settings.officegetgun.m4a1
          oggtable["rifle"] = settings.officegetgun.rifle
          ogg = true
          setGameKeyState(15, 255)
          wait(100)
          setGameKeyState(15, 0)
        end
      end
    end
  end

  local changeofficegetgunhotkey = function()
    sampShowDialog(
        989,
        "Изменение горячей клавиши активации getgun",
        'Нажмите "Окей", после чего нажмите нужную клавишу.\nНастройки будут изменены.',
        "Окей",
        "Закрыть"
    )
    while sampIsDialogActive(989) do
      wait(100)
    end
    local resultMain, buttonMain, typ = sampHasDialogRespond(989)
    if buttonMain == 1 then
      while ke1y == nil do
        wait(100)
        for i = 1, 200 do
          if isKeyDown(i) then
            settings.officegetgun.key = i
            sampAddChatMessage("Установлена новая горячая клавиша - " .. key.id_to_name(i), -1)
            addOneOffSound(0.0, 0.0, 0.0, 1052)
            inicfg.save(settings, "edith")
            ke1y = 1
            break
          end
        end
      end
      ke1y = nil
    end
  end

  local getMenu = function()
    return {
      title = "{7ef3fa}* " .. (settings.officegetgun.enable and "{00ff66}" or "{ff0000}") .. "OFFICEGETGUN",
      submenu = {
        {
          title = "Информация о модуле",
          onclick = function()
            sampShowDialog(
                0,
                "{7ef3fa}/edith v." ..
                    thisScript().version .. ' - информация о модуле {00ff66}"OFFICEGETGUN"',
                "{00ff66}OFFICEGETGUN{ffffff}\n{ffffff}Тупа гетгун\n\nПо нажатию хоткея {00ccff}" ..
                    tostring(key.id_to_name(settings.officegetgun.key)) ..
                    "{ffffff} берется оружие в офисе.\nВ настройках можно изменить хоткей и вкл/выкл модуль",
                "Окей"
            )
          end
        },
        {
          title = "Вкл/выкл модуля: " .. tostring(settings.officegetgun.enable),
          onclick = function()
            settings.officegetgun.enable = not settings.officegetgun.enable
            inicfg.save(settings, "edith")
          end
        },
        {
          title = " "
        },
        {
          title = "{AAAAAA}НАБОР ОРУЖИЯ"
        },
        {
          title = "* SDPISTOL: " .. tostring(settings.officegetgun.sdpistol),
          onclick = function()
            sampShowDialog(
                9827,
                "Количество дигла.",
                string.format("Введите количество дигла в наборе."),
                "Выбрать",
                "Закрыть",
                1
            )
            sampSetCurrentDialogEditboxText(settings.officegetgun.sdpistol)
            while sampIsDialogActive() do
              wait(100)
            end
            local result, button, list, input = sampHasDialogRespond(9827)
            if button == 1 then
              if
              tonumber(sampGetCurrentDialogEditboxText(9827)) ~= nil and
                  tonumber(sampGetCurrentDialogEditboxText(987)) >= 0 and
                  tonumber(sampGetCurrentDialogEditboxText(987)) < 10
              then
                settings.officegetgun.sdpistol = tonumber(sampGetCurrentDialogEditboxText(9827))
              end
            end
            inicfg.save(settings, "edith")
          end
        },
        {
          title = "* DEAGLE: " .. tostring(settings.officegetgun.deagle),
          onclick = function()
            sampShowDialog(
                9827,
                "Количество дигла.",
                string.format("Введите количество дигла в наборе."),
                "Выбрать",
                "Закрыть",
                1
            )
            sampSetCurrentDialogEditboxText(settings.officegetgun.deagle)
            while sampIsDialogActive() do
              wait(100)
            end
            local result, button, list, input = sampHasDialogRespond(9827)
            if button == 1 then
              if
              tonumber(sampGetCurrentDialogEditboxText(9827)) ~= nil and
                  tonumber(sampGetCurrentDialogEditboxText(987)) >= 0 and
                  tonumber(sampGetCurrentDialogEditboxText(987)) < 10
              then
                settings.officegetgun.deagle = tonumber(sampGetCurrentDialogEditboxText(9827))
              end
            end
            inicfg.save(settings, "edith")
          end
        },
        {
          title = "* SHOTGUN: " .. tostring(settings.officegetgun.shotgun),
          onclick = function()
            sampShowDialog(
                9827,
                "Количество дигла.",
                string.format("Введите количество дигла в наборе."),
                "Выбрать",
                "Закрыть",
                1
            )
            sampSetCurrentDialogEditboxText(settings.officegetgun.shotgun)
            while sampIsDialogActive() do
              wait(100)
            end
            local result, button, list, input = sampHasDialogRespond(9827)
            if button == 1 then
              if
              tonumber(sampGetCurrentDialogEditboxText(9827)) ~= nil and
                  tonumber(sampGetCurrentDialogEditboxText(987)) >= 0 and
                  tonumber(sampGetCurrentDialogEditboxText(987)) < 10
              then
                settings.officegetgun.shotgun = tonumber(sampGetCurrentDialogEditboxText(9827))
              end
            end
            inicfg.save(settings, "edith")
          end
        },
        {
          title = "* SMG: " .. tostring(settings.officegetgun.smg),
          onclick = function()
            sampShowDialog(
                9827,
                "Количество дигла.",
                string.format("Введите количество дигла в наборе."),
                "Выбрать",
                "Закрыть",
                1
            )
            sampSetCurrentDialogEditboxText(settings.officegetgun.smg)
            while sampIsDialogActive() do
              wait(100)
            end
            local result, button, list, input = sampHasDialogRespond(9827)
            if button == 1 then
              if
              tonumber(sampGetCurrentDialogEditboxText(9827)) ~= nil and
                  tonumber(sampGetCurrentDialogEditboxText(987)) >= 0 and
                  tonumber(sampGetCurrentDialogEditboxText(987)) < 10
              then
                settings.officegetgun.smg = tonumber(sampGetCurrentDialogEditboxText(9827))
              end
            end
            inicfg.save(settings, "edith")
          end
        },
        {
          title = "* AK47: " .. tostring(settings.officegetgun.ak47),
          onclick = function()
            sampShowDialog(
                9827,
                "Количество дигла.",
                string.format("Введите количество дигла в наборе."),
                "Выбрать",
                "Закрыть",
                1
            )
            sampSetCurrentDialogEditboxText(settings.officegetgun.ak47)
            while sampIsDialogActive() do
              wait(100)
            end
            local result, button, list, input = sampHasDialogRespond(9827)
            if button == 1 then
              if
              tonumber(sampGetCurrentDialogEditboxText(9827)) ~= nil and
                  tonumber(sampGetCurrentDialogEditboxText(987)) >= 0 and
                  tonumber(sampGetCurrentDialogEditboxText(987)) < 10
              then
                settings.officegetgun.ak47 = tonumber(sampGetCurrentDialogEditboxText(9827))
              end
            end
            inicfg.save(settings, "edith")
          end
        },
        {
          title = "* M4A1: " .. tostring(settings.officegetgun.m4a1),
          onclick = function()
            sampShowDialog(
                9827,
                "Количество дигла.",
                string.format("Введите количество дигла в наборе."),
                "Выбрать",
                "Закрыть",
                1
            )
            sampSetCurrentDialogEditboxText(settings.officegetgun.m4a1)
            while sampIsDialogActive() do
              wait(100)
            end
            local result, button, list, input = sampHasDialogRespond(9827)
            if button == 1 then
              if
              tonumber(sampGetCurrentDialogEditboxText(9827)) ~= nil and
                  tonumber(sampGetCurrentDialogEditboxText(987)) >= 0 and
                  tonumber(sampGetCurrentDialogEditboxText(987)) < 10
              then
                settings.officegetgun.m4a1 = tonumber(sampGetCurrentDialogEditboxText(9827))
              end
            end
            inicfg.save(settings, "edith")
          end
        },
        {
          title = "* RIFLE: " .. tostring(settings.officegetgun.rifle),
          onclick = function()
            sampShowDialog(
                9827,
                "Количество дигла.",
                string.format("Введите количество дигла в наборе."),
                "Выбрать",
                "Закрыть",
                1
            )
            sampSetCurrentDialogEditboxText(settings.officegetgun.rifle)
            while sampIsDialogActive() do
              wait(100)
            end
            local result, button, list, input = sampHasDialogRespond(9827)
            if button == 1 then
              if
              tonumber(sampGetCurrentDialogEditboxText(9827)) ~= nil and
                  tonumber(sampGetCurrentDialogEditboxText(987)) >= 0 and
                  tonumber(sampGetCurrentDialogEditboxText(987)) < 10
              then
                settings.officegetgun.rifle = tonumber(sampGetCurrentDialogEditboxText(9827))
              end
            end
            inicfg.save(settings, "edith")
          end
        },
        {
          title = " "
        },
        {
          title = "Изменить горячую клавишу",
          onclick = function()
            table.insert(tempThreads, lua_thread.create(changeofficegetgunhotkey))
          end
        }
      }
    }
  end

  local description = function()
    return "{7ef3fa}* " ..
        (settings.officegetgun.enable and "{00ff66}" or "{ff0000}") ..
        "OFFICEGETGUN - {ffffff}МЕДЛЕННОЕ взятие набора оружия по нажатию кнопки {00ccff}" ..
        tostring(key.id_to_name(settings.officegetgun.key)) .. ""
  end

  local enableAll = function()
    settings.officegetgun.enable = true
  end

  local disableAll = function()
    settings.officegetgun.enable = false
  end

  local defaults = {
    enable = false,
    key = 78,
    sdpistol = 0,
    deagle = 2,
    shotgun = 0,
    smg = 0,
    ak47 = 0,
    m4a1 = 0,
    rifle = 1
  }

	local takeGun = function(id)
		table.insert(
			tempThreads,
			lua_thread.create(
				function(id)
					local st = os.clock()
					repeat
						wait(300)
						if os.clock() - st > 5 then
							return
						end
					until os.clock() - st < 5 and sampIsDialogActive() and not sampIsChatInputActive() and
						sampGetCurrentDialogId() == 1160
					wait(300)
					sampSetCurrentDialogListItem(id)
					print(os.clock(), sampIsDialogActive(), "БЕРУ " .. tostring(id))
					wait(300)
					setVirtualKeyDown(VK_RETURN, true)
					setVirtualKeyDown(VK_RETURN, false)

					if
						oggtable["sdpistol"] == 0 and oggtable["deagle"] == 0 and oggtable["shotgun"] == 0 and
							oggtable["smg"] == 0 and
							oggtable["ak47"] == 0 and
							oggtable["m4a1"] == 0 and
							oggtable["rifle"] == 0
					 then
						local st = os.clock()
						repeat
							wait(0)
							print("work")
							if os.clock() - st > 1 then
								return
							end
						until os.clock() - st < 1 and sampIsDialogActive() and not sampIsChatInputActive() and
							sampGetCurrentDialogId() == 1160
						print("close")
						wait(1000)
						sampCloseCurrentDialogWithButton(0)
					end
				end,
				id
			)
		)
	end

  local onShowDialog = function(dialog, style, title, button1, button2, text)
    if dialog == 1160 and ogg then
      print(os.clock(), "DIALOG")
      if oggtable["sdpistol"] > 0 then
        oggtable["sdpistol"] = oggtable["sdpistol"] - 1
        takeGun(0)
        print(os.clock(), "БЕРУ sdpistol")
      elseif oggtable["deagle"] > 0 then
        oggtable["deagle"] = oggtable["deagle"] - 1
        takeGun(1)
        print(os.clock(), "БЕРУ deagle")
      elseif oggtable["shotgun"] > 0 then
        oggtable["shotgun"] = oggtable["shotgun"] - 1
        takeGun(2)
        print(os.clock(), "БЕРУ shotgun")
      elseif oggtable["smg"] > 0 then
        oggtable["smg"] = oggtable["smg"] - 1
        takeGun(3)
        print(os.clock(), "БЕРУ smg")
      elseif oggtable["ak47"] > 0 then
        oggtable["ak47"] = oggtable["ak47"] - 1
        takeGun(4)
        print(os.clock(), "БЕРУ ak47")
      elseif oggtable["m4a1"] > 0 then
        oggtable["m4a1"] = oggtable["m4a1"] - 1
        takeGun(5)
        print(os.clock(), "БЕРУ m4a1")
      elseif oggtable["rifle"] > 0 then
        oggtable["rifle"] = oggtable["rifle"] - 1
        print(os.clock(), "БЕРУ РИФЛУ")
        takeGun(6)
      end
    end
  end

  return {
    main = mainThread,
    getMenu = getMenu,
    desc = description,
    enable = enableAll,
    disable = disableAll,
    defaults = defaults,
    onShowDialog = onShowDialog
  }
end
--------------------------------------------------------------------------------
------------------------------------TEMPLATE------------------------------------
--------------------------------------------------------------------------------
--[[function xxxModule()
  local mainThread = function()

  end

  local getMenu = function()
    return
  end

  local description = function()
    return
  end

  local enableAll = function()

  end

  local disableAll = function()

  end

  local defaults = {
  }

  local f = function()

  end

  return {
    main = mainThread,
    getMenu = getMenu,
    desc = description,
    enable = enableAll,
    disable = disableAll,
    defaults = defaults
  }
end]]
--------------------------------------------------------------------------------
-------------------------------------EVENTS-------------------------------------
--------------------------------------------------------------------------------
function processEvent(func, args)
  if args == nil then
    args = {}
  end
  local kk = table.pack(func(table.unpack(args)))
  if kk.n > 0 then
    return kk
  end
end

function onServerMessage(color, text)
  local res = processEvent(storoj.onServerMessage, table.pack(color, text))
  if res then
    return table.unpack(res)
  end

  local res = processEvent(struck.onServerMessage, table.pack(color, text))
  if res then
    return table.unpack(res)
  end

  local res = processEvent(tweaks.onServerMessageAdBlock, table.pack(color, text))
  if res then
    return table.unpack(res)
  end

  local res = processEvent(tweaks.onServerMessageHideShit, table.pack(color, text))
  if res then
    return table.unpack(res)
  end

  local res = processEvent(tweaks.onServerMessageHideGov, table.pack(color, text))
  if res then
    return table.unpack(res)
  end

  local res = processEvent(drugsmats.onServerMessage, table.pack(color, text))
  if res then
    return table.unpack(res)
  end

  local res = processEvent(cipher.onServerMessage, table.pack(color, text))
  if res then
    return table.unpack(res)
  end

  local res = processEvent(capturetimer.onServerMessage, table.pack(color, text))
  if res then
    return table.unpack(res)
  end

  local res = processEvent(bikerlist.onServerMessage, table.pack(color, text))
  if res then
    return table.unpack(res)
  end

  local res = processEvent(liker.onServerMessage, table.pack(color, text))
  if res then
    return table.unpack(res)
  end

  local res = processEvent(healme.onServerMessage, table.pack(color, text))
  if res then
    return table.unpack(res)
  end

  local res = processEvent(deathlist.onServerMessage, table.pack(color, text))
  if res then
    return table.unpack(res)
  end

  local res = processEvent(ganghelper.onServerMessage, table.pack(color, text))
  if res then
    return table.unpack(res)
  end

  local res = processEvent(bikerinfo.onServerMessage, table.pack(color, text))
  if res then
    return table.unpack(res)
  end

  local res = processEvent(adr.onServerMessage, table.pack(color, text))
  if res then
    return table.unpack(res)
  end

  local res = processEvent(checker.onServerMessage, table.pack(color, text))
  if res then
    return table.unpack(res)
  end
end

function onSetPlayerPos()
  local res = processEvent(deathlist.onSetPlayerPos)
  if res then
    return table.unpack(res)
  end
end

function onSendGiveDamage(playerID, damage, weaponID, bodypart)
  local res = processEvent(score.onSendGiveDamage, table.pack(playerID, damage, weaponID, bodypart))
  if res then
    return table.unpack(res)
  end
  local res = processEvent(deathlist.onSendGiveDamage, table.pack(playerID, damage, weaponID, bodypart))
  if res then
    return table.unpack(res)
  end
end

function onSendTakeDamage(playerID, damage, weaponID, bodypart)
  local res = processEvent(score.onSendTakeDamage, table.pack(playerID, damage, weaponID, bodypart))
  if res then
    return table.unpack(res)
  end
  local res = processEvent(deathlist.onSendTakeDamage, table.pack(playerID, damage, weaponID, bodypart))
  if res then
    return table.unpack(res)
  end
end

function onSendCommand(cmd)
  local res = processEvent(warnings.onSendCommand, table.pack(cmd))
  if res then
    return table.unpack(res)
  end
  local res = processEvent(vspiwka.onSendCommand, table.pack(cmd))
  if res then
    return table.unpack(res)
  end
  local res = processEvent(parashute.onSendCommand, table.pack(cmd))
  if res then
    return table.unpack(res)
  end
  local res = processEvent(healme.onSendCommand, table.pack(cmd))
  if res then
    return table.unpack(res)
  end
  local res = processEvent(iznanka.onSendCommand, table.pack(cmd))
  if res then
    return table.unpack(res)
  end
  local res = processEvent(liker.onSendCommand, table.pack(cmd))
  if res then
    return table.unpack(res)
  end
  local res = processEvent(storoj.onSendCommand, table.pack(cmd))
  if res then
    return table.unpack(res)
  end
  local res = processEvent(cipher.onSendCommand, table.pack(cmd))
  if res then
    return table.unpack(res)
  end
  local res = processEvent(struck.onSendCommand, table.pack(cmd))
  if res then
    return table.unpack(res)
  end
  local res = processEvent(drugsmats.onSendCommand, table.pack(cmd))
  if res then
    return table.unpack(res)
  end
  local res = processEvent(rcapture.onSendCommand, table.pack(cmd))
  if res then
    return table.unpack(res)
  end
  local res = processEvent(capturetimer.onSendCommand, table.pack(cmd))
  if res then
    return table.unpack(res)
  end
  local res = processEvent(ganghelper.onSendCommand, table.pack(cmd))
  if res then
    return table.unpack(res)
  end
  local res = processEvent(checker.onSendCommand, table.pack(cmd))
  if res then
    return table.unpack(res)
  end
end

function onSendChat(message)
  local res = processEvent(warnings.onSendChat, table.pack(message))
  if res then
    return table.unpack(res)
  end
  local res = processEvent(vspiwka.onSendChat, table.pack(message))
  if res then
    return table.unpack(res)
  end
  local res = processEvent(parashute.onSendChat, table.pack(message))
  if res then
    return table.unpack(res)
  end
  local res = processEvent(healme.onSendChat, table.pack(message))
  if res then
    return table.unpack(res)
  end
  local res = processEvent(iznanka.onSendChat, table.pack(message))
  if res then
    return table.unpack(res)
  end
  local res = processEvent(storoj.onSendChat, table.pack(message))
  if res then
    return table.unpack(res)
  end
  local res = processEvent(liker.onSendChat, table.pack(message))
  if res then
    return table.unpack(res)
  end
  local res = processEvent(struck.onSendChat, table.pack(message))
  if res then
    return table.unpack(res)
  end
  local res = processEvent(drugsmats.onSendChat, table.pack(message))
  if res then
    return table.unpack(res)
  end
  local res = processEvent(rcapture.onSendChat, table.pack(message))
  if res then
    return table.unpack(res)
  end
  local res = processEvent(capturetimer.onSendChat, table.pack(message))
  if res then
    return table.unpack(res)
  end
  local res = processEvent(ganghelper.onSendChat, table.pack(message))
  if res then
    return table.unpack(res)
  end
  local res = processEvent(checker.onSendChat, table.pack(message))
  if res then
    return table.unpack(res)
  end
end

function onCreatePickup(id, model, pickuptype, position)
  local res = processEvent(heistbeep.onCreatePickup, table.pack(id, model, pickuptype, position))
  if res then
    return table.unpack(res)
  end
end

function onSetMapIcon(iconId, position, type, color, style)
  local res = processEvent(glonass.onSetMapIcon, table.pack(iconId, position, type, color, style))
  if res then
    return table.unpack(res)
  end
end

function onSendPickedUpPickup(id)
  local res = processEvent(heistbeep.onSendPickedUpPickup, table.pack(id))
  if res then
    return table.unpack(res)
  end
end

function onPlayerChatBubble(id, col, dist, dur, msg)
  local res = processEvent(camhack.onPlayerChatBubble, table.pack(id, col, dist, dur, msg))
  if res then
    return table.unpack(res)
  end
end

function onSendAimSync()
  local res = processEvent(camhack.onSendAimSync)
  if res then
    return table.unpack(res)
  end
end

function onSendDialogResponse(dialogId, button, listboxId, input)
  local res = processEvent(storoj.onSendDialogResponse, table.pack(dialogId, button, listboxId, input))
  if res then
    return table.unpack(res)
  end

  local res = processEvent(acapture.onSendDialogResponse, table.pack(dialogId, button, listboxId, input))
  if res then
    return table.unpack(res)
  end

  local res = processEvent(rcapture.onSendDialogResponse, table.pack(dialogId, button, listboxId, input))
  if res then
    return table.unpack(res)
  end
end

function onShowDialog(dialog, style, title, button1, button2, text)
  local res = processEvent(drugsmats.onShowDialog, table.pack(dialog, style, title, button1, button2, text))
  if res then
    return table.unpack(res)
  end

  local res = processEvent(storoj.onShowDialog, table.pack(dialog, style, title, button1, button2, text))
  if res then
    return table.unpack(res)
  end

  local res = processEvent(getgun.onShowDialog, table.pack(dialog, style, title, button1, button2, text))
  if res then
    return table.unpack(res)
  end

  local res = processEvent(acapture.onShowDialog, table.pack(dialog, style, title, button1, button2, text))
  if res then
    return table.unpack(res)
  end

  local res = processEvent(rcapture.onShowDialog, table.pack(dialog, style, title, button1, button2, text))
  if res then
    return table.unpack(res)
  end

  local res = processEvent(bikerinfo.onShowDialog, table.pack(dialog, style, title, button1, button2, text))
  if res then
    return table.unpack(res)
  end

  local res = processEvent(officegetgun.onShowDialog, table.pack(dialog, style, title, button1, button2, text))
  if res then
    return table.unpack(res)
  end
end

function onCreateGangZone(zoneId, squareStart, squareEnd, color)
  local res = processEvent(gzcheck.onCreateGangZone, table.pack(zoneId, squareStart, squareEnd, color))
  if res then
    return table.unpack(res)
  end
end

function onGangZoneDestroy(zoneId)
  local res = processEvent(gzcheck.onGangZoneDestroy, table.pack(zoneId))
  if res then
    return table.unpack(res)
  end
end

function onGangZoneFlash(zoneId, color)
  local res = processEvent(gzcheck.onGangZoneFlash, table.pack(zoneId, color))
  if res then
    return table.unpack(res)
  end
end

function onGangZoneStopFlash(zoneId)
  local res = processEvent(gzcheck.onGangZoneStopFlash, table.pack(zoneId))
  if res then
    return table.unpack(res)
  end
end

function onSetInterior(id)
  local res = processEvent(healme.onSetInterior, table.pack(id))
  if res then
    return table.unpack(res)
  end
end

function onShowTextDraw(id, tab)
  local res = processEvent(deathlist.onShowTextDraw, table.pack(id, tab))
  if res then
    return table.unpack(res)
  end

  local res = processEvent(capturetimer.onShowTextDraw, table.pack(id, tab))
  if res then
    return table.unpack(res)
  end
end

function onTextDrawSetString(id, text)
  local res = processEvent(capturetimer.onTextDrawSetString, table.pack(id, text))
  if res then
    return table.unpack(res)
  end
end

function onTextDrawHide(id)
  local res = processEvent(deathlist.onTextDrawHide, table.pack(id))
  if res then
    return table.unpack(res)
  end
end

function onPlayerDeath(pID)
  local res = processEvent(warnings.onPlayerDeath, table.pack(pID))
  if res then
    return table.unpack(res)
  end
  local res = processEvent(deathlist.onPlayerDeath, table.pack(pID))
  if res then
    return table.unpack(res)
  end
end

function onCreate3DText(id, color, position, distance, testLOS, attachedPlayerId, attachedVehicleId, text)
  local res = processEvent(deathlist.onCreate3DText, table.pack(id, color, position, distance, testLOS, attachedPlayerId, attachedVehicleId, text))
  if res then
    return table.unpack(res)
  end
end

function enableEvents()
  sampev.onServerMessage = onServerMessage
  sampev.onSetPlayerPos = onSetPlayerPos
  sampev.onSendGiveDamage = onSendGiveDamage
  sampev.onSendTakeDamage = onSendTakeDamage
  sampev.onSendCommand = onSendCommand
  sampev.onCreatePickup = onCreatePickup
  sampev.onSetMapIcon = onSetMapIcon
  sampev.onSendPickedUpPickup = onSendPickedUpPickup
  sampev.onPlayerChatBubble = onPlayerChatBubble
  sampev.onSendAimSync = onSendAimSync
  sampev.onSendDialogResponse = onSendDialogResponse
  sampev.onShowDialog = onShowDialog
  sampev.onCreateGangZone = onCreateGangZone
  sampev.onGangZoneDestroy = onGangZoneDestroy
  sampev.onSendChat = onSendChat
  sampev.onSetInterior = onSetInterior
  sampev.onShowTextDraw = onShowTextDraw
  sampev.onPlayerDeath = onPlayerDeath
  sampev.onCreate3DText = onCreate3DText
  sampev.onGangZoneFlash = onGangZoneFlash
  sampev.onGangZoneStopFlash = onGangZoneStopFlash
  sampev.onTextDrawHide = onTextDrawHide
  sampev.onTextDrawSetString = onTextDrawSetString
end

function add_to_changelog(title, text)
  local sub_log = {}
  for string in string.gmatch(text, '[^\n]+') do
    table.insert(sub_log,
            {
              title = string
            }
    )
  end
  table.insert(
          changelog_menu,
          {
            title = title,
            submenu = sub_log
          }
  )
end

updatechangelog()

function showlog()
  submenus_show(changelog_menu, "{348cb2}EDITH v." .. thisScript().version .. " changelog", "Выбрать", "Закрыть", "Назад")
end

--------------------------------------------------------------------------------
--------------------------------------3RD---------------------------------------
--------------------------------------------------------------------------------
-- made by FYP
function submenus_show(menu, caption, select_button, close_button, back_button, callback, start, pos)
  select_button, close_button, back_button = select_button or "Select", close_button or "Close", back_button or "Back"
  prev_menus = {}
  function display(menu, id, caption, start, pos)
    local string_list = {}
    for i, v in ipairs(menu) do
      table.insert(string_list, type(v.submenu) == "table" and v.title .. "  >>" or v.title)
    end
    if not start then
      sampShowDialog(
              id,
              caption,
              table.concat(string_list, "\n"),
              select_button,
              (#prev_menus > 0) and back_button or close_button,
              4
      )
      if pos then
        sampSetCurrentDialogListItem(pos)
        if pos > 20 then
          setVirtualKeyDown(40, true)
          setVirtualKeyDown(40, false)
          setVirtualKeyDown(38, true)
          setVirtualKeyDown(38, false)
        end
      end
      pos = nil
    end

    repeat
      wait(0)
      local result, button, list = sampHasDialogRespond(id)
      if start then
        result, button, list = true, 1, start - 1
      end
      if result then
        if button == 1 and list ~= -1 then
          local item = menu[list + 1]
          if type(item.submenu) == "table" then
            -- submenu
            table.insert(prev_menus, { menu = menu, caption = caption, id = list + 1 })
            if type(item.onclick) == "function" then
              item.onclick(menu, list + 1, item.submenu)
            end
            return display(item.submenu, id + 1, item.submenu.title and item.submenu.title or item.title, nil, pos)
          elseif type(item.onclick) == "function" then
            local result = item.onclick(menu, list + 1)
            if not result then
              if prev_menus and prev_menus[#prev_menus] and prev_menus[#prev_menus].id then
                if callback then
                  callback(prev_menus[#prev_menus].id, list, item.title)
                end
              end
              return result
            end
            return display(menu, id, caption)
          end
        else
          -- if button == 0
          if #prev_menus > 0 then
            local prev_menu = prev_menus[#prev_menus]
            prev_menus[#prev_menus] = nil
            return display(prev_menu.menu, id - 1, prev_menu.caption, nil, prev_menu.id - 1)
          end
          return false
        end
      end
    until result
  end
  return display(menu, 31337, caption or menu.title, start, pos)
end