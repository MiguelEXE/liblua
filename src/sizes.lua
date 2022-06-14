local lib = {}

local checkArg = require("checkArg")

local suffix = {
  [0]="b", "K", "M", "G", "T", "P"
}

function lib.format(size, base, ssuffix)
  checkArg(1, size, "number")
  checkArg(2, base, "number", "nil")
  checkArg(3, ssuffix, "string", "nil")
  base = base or 1024
  ssuffix = ssuffix or ""
  local i = 0
  while size > base do
    i = i + 1
    size = size / base
  end
  return string.format("%d%s%s", math.floor(size), suffix[i],
    i > 0 and ssuffix or (" "):rep(#ssuffix))
end

function lib.format10(size)
  return lib.format(size, 1000, "i")
end

return lib
