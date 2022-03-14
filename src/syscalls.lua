-- system call wrappers --

local lib = {}

local function unpackResult(result)
  if not result[1] then
    if type(result[2]) == "string" then
      error(result[2], 0)
    end
    return nil, result[2]
  end
  return table.unpack(result, 1, result.n)
end

setmetatable(lib, {__index = function(key)
  lib[key] = function(...)
    local result = table.pack(coroutine.yield("syscall", key, ...))
    return unpackResult(result)
  end
  return lib[key]
end})

return lib
