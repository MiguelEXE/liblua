-- localization! --

local sys = require("syscalls")
local stdio = require("stdio")

local lib = {}

local mapcache = {}

-- find a locale e.g. `/etc/lang/en_US-errors.lua`
local function findmap(mapid, lang)
  local path = sys.getenv("LC_PATH") or
    "/usr/share/lang/#-?.lua;/etc/lang/#-?.lua"
  for search in path:gmatch() do
    search = search:gsub("#", lang):gsub("%?", mapid)
    if sys.stat(search) then
      return search
    end
  end
  return nil, lang.."-"..mapid..": language file not found"
end

local function loadmap(id)
  local lang = sys.getenv("LC_LOCALE") or "en_US"
  local fullid = lang .. "-" .. id
  if mapcache[fullid] then return mapcache[fullid] end

  local path, err = findmap(id, lang)
  if not path then
    stdio.fprintf(stdio.stderr, "%s\n", err)
    return nil, err
  end

  local fd
  fd, err = sys.open(path, "r")
  if not fd then
    stdio.fprintf(stdio.stderr, "%s: errno %d\n", err)
    return nil, err
  end

  local data = sys.read(fd, "a")
  sys.close(fd)

  local call
  call, err = load("return " .. data, "="..path, "t", {})
  if not call then
    stdio.fprintf(stdio.stderr, "%s\n", err)
    return nil, err
  end

  local suc, ret = pcall(call)
  if not suc then
    stdio.fprintf(stdio.stderr, "%s\n", ret)
    return nil, ret
  end

  mapcache[fullid] = ret

  return ret
end

function lib.fetch(map, key)
  local lmap = loadmap(map)
  return lmap[key]
end

return lib
