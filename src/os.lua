-- os library bits

local sys = require("syscalls")

function os.getenv(k)
  return sys.environ()[k]
end

function os.setenv(k, v)
  sys.environ()[k] = v
end
