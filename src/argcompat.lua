--- Cross-platform command arguments
-- Cynosure 2 passes command arguments as a table, rather than as a set of separate arguments.  The Lua REPL included with ULOS 2 manages this, but this module is provided nonetheless.
-- @module argcompat

return {
  --- Coerce arguments into a table.
  -- The first argument must always be the default name of the command.  If the second argument is a table then it is returned as-is;  otherwise, all arguments are placed ino a table with index 0 being `cmd`.
  -- @function argcompat.command
  -- @tparam string cmd The default command name
  -- @param ... Any remaining arguments
  -- @treturn table The arguments as a table
  command = function(cmd, ...)
    local argv = table.pack(...)
    if type(argv[1]) == "table" then
      return argv[1]
    end
    argv[0] = cmd
    return argv
  end
}
