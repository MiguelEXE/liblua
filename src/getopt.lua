-- Argument parser from ULOS 1

local lib = {}

function lib.getopt(_opts, ...)
  checkArg(1, _opts, "table")
  local _args = table.pack(...)
  local args, opts = {}, {}
  local skip_next, done = false, false
  for i, arg in ipairs(_args) do
    if skip_next then skip_next = false
    elseif arg:sub(1,1) == "-" and not done then
      if arg == "--" and opts.allow_finish then
        done = true
      elseif arg:match("%-%-(.+)") then
        arg = arg:sub(3)
        if _opts.options[arg] ~= nil then
          if _opts.options[arg] then
            if (not _args[i+1]) then
              io.stderr:write("option '", arg, "' requires an argument\n")
              if opts.help_message then
                io.stderr:write(opts.help_message, "\n")
              end
              os.exit(1)
            end
            opts[arg] = _args[i+1]
            skip_next = true
          else
            opts[arg] = true
          end
        elseif _opts.exit_on_bad_opt then
          io.stderr:write("unrecognized option '", arg, "'\n")
          if opts.help_message then
            io.stderr:write(opts.help_message, "\n")
          end
          os.exit(1)
        end
      else
        arg = arg:sub(2)
        if _opts.options[arg:sub(1,1)] then
          local a = arg:sub(1,1)
          if #arg == 1 then
            if not _args[i+1] then
              io.stderr:write("option '", arg, "' requires an argument\n")
              if opts.help_message then
                io.stderr:write(opts.help_message, "\n")
              end
              os.exit(1)
            end
            opts[a] = _args[i+1]
            skip_next = true
          else
            opts[a] = arg:sub(2)
          end
        else
          for c in arg:gmatch(".") do
            if _opts.options[c] == nil then
              if _opts.exit_on_bad_opt then
                io.stderr:write("unreciognized option '", arg, "'\n")
                if opts.help_message then
                  io.stderr:write(opts.help_message, "\n")
                end
                os.exit(1)
              end
            elseif _opts.options[c] then
              if not _args[i+1] then
                io.stderr:write("option '", arg, "' requires an argument\n")
                if opts.help_message then
                  io.stderr:write(opts.help_message, "\n")
                end
                os.exit(1)
              end
              opts[c] = true
            else
              opts[c] = true
            end
          end
        end
      end
    else
      if _opts.finish_after_arg then
        done = true
      end
      args[#args+1] = arg
    end
  end
  return args, opts
end

return lib
