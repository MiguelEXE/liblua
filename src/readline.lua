--- A Readline implementation.
-- Provides a fairly complete readline function.  It supports line editing, history, and obfuscation.
-- Loading this with `require` will provide only a single function, @{readline}.
-- @module readline

local termio = require("termio")
local checkArg = require("checkArg")

local rlid = 0

------
-- Readline options.  All fields in this table are optional.
-- @tfield string prompt A prompt to display
-- @tfield table history A table of history
-- @tfield boolean noexit Do not exit on `^D`
-- @tfield function exit A function to call instead of `os.exit` when `^D` is pressed, unless `noexit` is set
-- @table rlopts

--- Read a line of input.
-- @function readline
-- @tparam[opt] @{rlopts} opts Readline options
-- @treturn string The input that was read
local function readline(opts)
  checkArg(1, opts, "table", "nil")

  local uid = rlid + 1
  rlid = uid
  opts = opts or {}
  if opts.prompt then io.write(opts.prompt) end

  local history = opts.history or {}
  history[#history+1] = ""
  local hidx = #history

  local buffer = ""
  local cpos = 0

  local _, h = termio.getTermSize()

  while true do
    local key, flags = termio.readKey()
    flags = flags or {}
    if not (flags.ctrl or flags.alt) then
      if key == "up" then
        if hidx > 1 then
          if hidx == #history then
            history[#history] = buffer
          end
          hidx = hidx - 1
          local olen = #buffer - cpos
          cpos = 0
          buffer = history[hidx]
          if olen > 0 then io.write(string.format("\27[%dD", olen)) end
          local _, cy = termio.getCursor()
          if cy < h then
            io.write(string.format("\27[K\27[B\27[J\27[A%s", buffer))
          else
            io.write(string.format("\27[K%s", buffer))
          end
        end
      elseif key == "down" then
        if hidx < #history then
          hidx = hidx + 1
          local olen = #buffer - cpos
          cpos = 0
          buffer = history[hidx]
          if olen > 0 then io.write(string.format("\27[%dD", olen)) end
          local _, cy = termio.getCursor()
          if cy < h then
            io.write(string.format("\27[K\27[B\27[J\27[A%s", buffer))
          else
            io.write(string.format("\27[K%s", buffer))
          end
        end
      elseif key == "left" then
        if cpos < #buffer then
          cpos = cpos + 1
          io.write("\27[D")
        end
      elseif key == "right" then
        if cpos > 0 then
          cpos = cpos - 1
          io.write("\27[C")
        end
      elseif key == "backspace" then
        if cpos == 0 and #buffer > 0 then
          buffer = buffer:sub(1, -2)
          io.write("\27[D \27[D")
        elseif cpos < #buffer then
          buffer = buffer:sub(0, #buffer - cpos - 1) ..
            buffer:sub(#buffer - cpos + 1)
          local tw = buffer:sub((#buffer - cpos) + 1)
          io.write(string.format("\27[D%s \27[%dD", tw, cpos + 1))
        end
      elseif #key == 1 then
        local wr = true
        if cpos == 0 then
          buffer = buffer .. key
          io.write(key)
          wr = false
        elseif cpos == #buffer then
          buffer = key .. buffer
        else
          buffer = buffer:sub(1, #buffer - cpos) .. key ..
            buffer:sub(#buffer - cpos + 1)
        end
        if wr then
          local tw = buffer:sub(#buffer - cpos)
          io.write(string.format("%s\27[%dD", tw, #tw - 1))
        end
      end
    elseif flags.ctrl then
      if key == "m" then -- enter
        if cpos > 0 then io.write(string.format("\27[%dC", cpos)) end
        io.write("\n")
        break
      elseif key == "a" and cpos < #buffer then
        io.write(string.format("\27[%dD", #buffer - cpos))
        cpos = #buffer
      elseif key == "e" and cpos > 0 then
        io.write(string.format("\27[%dC", cpos))
        cpos = 0
      elseif key == "d" and not opts.noexit then
        io.write("\n")
        ; -- this is a weird lua quirk
        (type(opts.exit) == "function" and opts.exit or os.exit)()
      elseif key == "i" then -- tab
        if type(opts.complete) == "function" and cpos == 0 then
          local obuffer = buffer
          buffer = opts.complete(buffer, rlid) or buffer
          if obuffer ~= buffer and #obuffer > 0 then
            io.write(string.format("\27[%dD", #obuffer - cpos))
            cpos = 0
            local _, cy = termio.getCursor()
            if cy < h then
              io.write(string.format("\27[K\27[B\27[J\27[A%s", buffer))
            else
              io.write(string.format("\27[K%s", buffer))
            end
          end
        end
      end
    end
  end

  history[#history] = buffer
  return buffer
end

return readline
