local sys = require("system")

print [[

An example to display a spinner, whilst a long running task executes.

]]

if sys.windows then
  -- Windows holds multiple copies of environment variables, to ensure `getenv`
  -- returns what `setenv` sets we need to use the `system.getenv` instead of
  -- `os.getenv`.
  os.getenv = sys.getenv  -- luacheck: ignore

  -- Set console output to UTF-8 encoding.
  sys.setconsoleoutputcp(sys.CODEPAGE_UTF8)

  -- Set up the terminal to handle ANSI escape sequences on Windows.
  if sys.isatty(io.stdout) then
    sys.setconsoleflags(io.stdout, sys.getconsoleflags(io.stdout) + sys.COF_VIRTUAL_TERMINAL_PROCESSING)
  end
  if sys.isatty(io.stderr) then
    sys.setconsoleflags(io.stderr, sys.getconsoleflags(io.stderr) + sys.COF_VIRTUAL_TERMINAL_PROCESSING)
  end
  if sys.isatty(io.stdin) then
    sys.setconsoleflags(io.stdin, sys.getconsoleflags(io.stdout) + sys.CIF_VIRTUAL_TERMINAL_INPUT)
  end
end

-- start make backup, to auto-restore on exit
sys.autotermrestore()
-- configure console
sys.setconsoleflags(io.stdin, sys.getconsoleflags(io.stdin) - sys.CIF_ECHO_INPUT - sys.CIF_LINE_INPUT)
local of = sys.tcgetattr(io.stdin)
sys.tcsetattr(io.stdin, sys.TCSANOW, { lflag = of.lflag - sys.L_ICANON - sys.L_ECHO })
sys.setnonblock(io.stdin, true)



local function hideCursor()
  io.write("\27[?25l")
  io.flush()
end

local function showCursor()
  io.write("\27[?25h")
  io.flush()
end

local function left(n)
  io.write("\27[",n or 1,"D")
  io.flush()
end



local spinner do
  local spin = [[|/-\]]
  local i = 1
  spinner = function()
    hideCursor()
    io.write(spin:sub(i, i))
    left()
    i = i + 1
    if i > #spin then i = 1 end

    if sys.readkey(0) ~= nil then
      while sys.readkey(0) ~= nil do end -- consume keys pressed
      io.write(" ");
      left()
      showCursor()
      return true
    else
      return false
    end
  end
end

io.stdout:write("press any key to stop the spinner... ")
while not spinner() do
  sys.sleep(0.1)
end

print("Done!")
