-- Argument parser from ULOS 1

local lib = {}

function lib.getopt(_opts, _args)
  checkArg(1, _opts, "table")
  checkArg(2, _args, "table")

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

              if _opts.help_message then
                io.stderr:write(_opts.help_message)
              end

              os.exit(1)
            end

            opts[arg] = opts[arg] or {}
            table.insert(opts[arg], _args[i+1])
            skip_next = true

          else
            opts[arg] = true

          end

        elseif _opts.exit_on_bad_opt then
          io.stderr:write("unrecognized option '", arg, "'\n")

          if _opts.help_message then
            io.stderr:write(_opts.help_message)
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

              if _opts.help_message then
                io.stderr:write(_opts.help_message)
              end

              os.exit(1)
            end

            opts[a] = opts[a] or {}
            table.insert(opts[a], _args[i+1])
            skip_next = true

          else
            opts[a] = arg:sub(2)
          end

        else
          for c in arg:gmatch(".") do
            if _opts.options[c] == nil then
              if _opts.exit_on_bad_opt then
                io.stderr:write("unrecognized option '", arg, "'\n")

                if _opts.help_message then
                  io.stderr:write(_opts.help_message)
                end

                os.exit(1)
              end

            elseif _opts.options[c] then
              if not _args[i+1] then
                io.stderr:write("option '", arg, "' requires an argument\n")

                if _opts.help_message then
                  io.stderr:write(_opts.help_message)
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

  if not _opts.can_repeat_opts then
    for k, v in pairs(opts) do
      if type(v) == "table" then
        opts[k] = v[#v]
      end
    end
  end

  return args, opts
end

return lib
