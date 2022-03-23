-- io library implementation.
-- Due to how Cynosure 2 implements file streams,
-- this is a lot simpler than most OpenComputers
-- implementations of this library.

local sys = require("syscalls")
local get_err = require("errors").err

local lib = {}

local _iost = {
  read = function(self, ...)
    local results = {}
    for i, format in ipairs(table.pack(...)) do
      results[i] = sys.read(self.fd, format)
    end
    return table.unpack(results, 1, select("#", ...))
  end,

  lines = function(self, fmt)
    return function()
      return self:read(fmt or "l")
    end
  end,

  write = function(self, ...)
    local to_write = table.pack(...)
    for _, data in ipairs(to_write) do
      sys.write(self.fd, data)
    end
    return self
  end,

  seek = function(self, whence, offset)
    return sys.seek(self.fd, whence, offset)
  end,

  flush = function(self)
    return sys.flush(self.fd)
  end,

  close = function(self)
    return sys.close(self.fd)
  end,

  setvbuf = function(self, mode)
    return sys.ioctl(self.fd, "setvbuf", mode)
  end,
}

local function mkiost(fd)
  return setmetatable({fd=fd}, {__index=_iost})
end

lib.stdin = mkiost(0)
lib.stdout = mkiost(1)
lib.stderr = mkiost(2)

function lib.open(path, mode)
  checkArg(1, path, "string")
  checkArg(2, mode, "string", "nil")

  mode = mode or "r"

  local fd, err = sys.open(path, mode)
  if not fd then
    return nil, get_err(err)
  end

  return mkiost(fd)
end

function lib.read(...)
  return lib.stdin:read(...)
end

function lib.write(...)
  return lib.stdout:write(...)
end

function lib.flush()
  return lib.stdout:flush()
end

local function check(file)
  checkArg(1, file, "table")
  if not file.fd then error("bad argument #1 (bad file descriptor)", 2) end
  return true
end

function lib.input(file)
  if file then
    if type(file) == "string" then file = assert(io.open(file, "r")) end
    check(file)
    lib.stdin = file
  end
  return lib.stdin
end

function lib.output(file)
  if file then
    if type(file) == "string" then file = assert(io.open(file, "w")) end
    check(file)
    lib.stdout = file
  end
  return lib.stdout
end

function _G.print(...)
  local args = table.pack(...)

  for i=1, args.n, 1 do
    args[i] = tostring(args[i])
  end

  lib.stdout:write(table.concat(args, "\t"), "\n")

  return true
end

return lib
