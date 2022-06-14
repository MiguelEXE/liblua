-- os library bits

local sys = require("syscalls")
local checkArg = require("checkArg")

function os.getenv(k)
  checkArg(1, k, "string")
  return sys.environ()[k]
end

function os.exit(n)
  checkArg(1, n, "number", "nil")
  sys.exit(n or 0)
end
