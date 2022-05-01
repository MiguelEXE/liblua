-- Cynosure 2 does arguments differently than Linux does

return {
  command = function(cmd, ...)
    local argv = table.pack(...)
    if type(argv[1]) == "table" then
      return argv[1]
    end
    argv[0] = cmd
    return argv
  end
}
