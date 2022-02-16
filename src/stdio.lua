-- some general functions --

local sys = require("syscalls")

local lib = {}

lib.stdin = 0
lib.stdout = 1
lib.stderr = 2

function lib.fprintf(fd, fmt, ...)
  return sys.write(fd, string.format(fmt, ...))
end

function lib.printf(fmt, ...)
  return lib.fprintf(lib.stdout, fmt, ...)
end

return lib
