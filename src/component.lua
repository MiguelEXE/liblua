-- for when you really need component access

local files = require("posix.dirent").files
local syscalls = require("syscalls")
local checkArg = require("checkArg")
local open = syscalls.open
local close = syscalls.close
local ioctl = syscalls.ioctl

local component = {}

local components = "/dev/components/"

local function is(ctype, want, exact)
  if not want then return true end

  if exact then
    return ctype:sub(0, #want) == want
  else
    return not not ctype:match(want)
  end
end

local map = {}

function component.list(ctype, exact)
  checkArg(1, ctype, "string", "nil")
  checkArg(2, exact, "boolean", "nil")
  local ret = {}

  for comptype in files(components) do
    if is(comptype, ctype, exact) then
      for comp in files(components..comptype) do
        local fd = open(components..comptype.."/"..comp, "r")
        local address = ioctl(fd, "address")
        map[address] = comp
        ret[address] = comptype
      end
    end
  end

  local k
  setmetatable(ret, {__call = function()
    k = next(ret, k)
    if k then return k, ret[k] end
  end})

  return ret
end

function component.proxy()
end

return component
