-- posix.sys.wait

local lib = {}

local wait = require("syscalls").wait
local errno = require("posix.errno")

function lib.wait(pid, options)
  checkArg(1, pid, "number")
  checkArg(2, options, "number", "nil")

  local reason, status = wait(pid)
  if not reason then
    return nil, errno.errno(status), status
  end

  return pid, reason, status
end

return lib
