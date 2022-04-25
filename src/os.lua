-- os library bits

local sys = require("syscalls")

function os.getenv(k)
  return sys.environ()[k]
end

function os.exit(n)
  sys.exit(n or 0)
end
