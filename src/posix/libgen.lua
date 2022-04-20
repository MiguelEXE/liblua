-- posix.libgen implementation

local function segments(path)
  local dir, base = path:match("^(.-)/?([^/]+)/?$")
  dir = (dir and #dir > 0 and dir) or "."
  base = (base and #base > 0 and base) or "."
  return dir, base
end

local lib = {}

function lib.basename(path)
  return select(2, segments(path))
end

function lib.dirname(path)
  return (segments(path))
end

return lib
