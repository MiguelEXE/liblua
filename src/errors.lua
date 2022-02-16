-- convert an error message to a name --

-- link against i18n
local lang = require("i18n")

local lib = {}

local map = {
  [1]   = "EPERM",
  [2]   = "ENOENT",
  [8]   = "ENOEXEC",
  [9]   = "EBADF",
  [13]  = "EACCES",
  [16]  = "EBUSY",
  [17]  = "EEXIST",
  [18]  = "EXDEV",
  [19]  = "ENODEV",
  [20]  = "ENOTDIR",
  [21]  = "EISDIR",
  [22]  = "EINVAL",
  [25]  = "ENOTTY",
  [49]  = "EUNATCH",
  [83]  = "ELIBEXEC",
  [95]  = "ENOTSUP",
}

function lib.err(id)
  checkArg(1, id, "number", "string")
  if type(id) == "string" then return id end
  return lang.fetch("errors", map[id] or "EUNKNOWN")
end

return lib
