-- system call wrappers --

local lib = {}

setmetatable(lib, {__index = function(key)
  return function(...)
    return syscall(key, ...)
  end
end})

return lib
