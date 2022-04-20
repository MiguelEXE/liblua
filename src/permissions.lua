-- permissions utilities

local order = {
  0x001,
  0x002,
  0x004,
  0x008,
  0x010,
  0x020,
  0x040,
  0x080,
  0x100,
}

local reverse = {
  "x",
  "w",
  "r",
  "x",
  "w",
  "r",
  "x",
  "w",
  "r",
}

local lib = {}
local errno = require("posix.errno")

function lib.strtobmp(permstr)
  checkArg(1, permstr, "string")

  if not permstr:match("[r%-][w%-][x%-][r%-][w%-][x%-][r%-][w%-][x%-]") then
    return nil, errno.errno(errno.EINVAL)
  end

  local bitmap = 0

  for i=#order, 1, -1 do
    local index = #order - i + 1
    if permstr:sub(index, index) ~= "-" then
      bitmap = bit32.bor(bitmap, order[i])
    end
  end

  return bitmap
end

function lib.bmptostr(bitmap)
  checkArg(1, bitmap, "number")

  local ret = ""

  for i=#order, 1, -1 do
    if bit32.band(bitmap, order[i]) ~= 0 then
      ret = ret .. reverse[i]
    else
      ret = ret .. "-"
    end
  end

  return ret
end

function lib.has_permission(ogo, mode, perm)
  checkArg(1, mode, "number")
  checkArg(2, perm, "string")

  local val_check = lib.strtobmp(perm)

  return bit32.band(mode, val_check) == val_check
end

return lib
