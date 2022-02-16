-- localization! --

local sys = require("syscalls")

local lib = {}

local maps = {}

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
  local path, err = findmap(id, lang)
  if not path then
    sys.printf(sys.stderr, err)
  end
end

function lib.fetch(map, key)
end

return lib
