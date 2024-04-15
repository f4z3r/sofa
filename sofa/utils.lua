local io = require("io")
local os = require("os")
local string = require("string")

local utils = {}

---trim leading and trailing whitespace from a string
---@param s string
---@return string
function utils.trim_whitespace(s)
  return s:match("^%s*(.-)%s*$")
end

---escape single quotes in strings
---@param s any
---@return unknown
function utils.escape_quotes(s)
  return s:gsub("'", "'\\''")
end

---run a command return the output
---@param cmd string
---@return number exit code
---@return string stdout from the command
function utils.run(cmd)
  local filename = os.tmpname()
  local command = string.format("%s > %s", cmd, filename)
  local exit = os.execute(command)
  local fh = assert(io.open(filename, "r"))
  local out = fh:read("*a")
  fh:close()
  os.remove(filename)
  return exit, out
end

---write a temporary file with some content
---@param content string
---@return string the filename to which the content was written
---@return function a function to call to delete the file
function utils.write_to_tmp(content)
  local filename = os.tmpname()
  local fh = assert(io.open(filename, "w+"))
  fh:write(content)
  fh:close()
  return filename, function()
    os.remove(filename)
  end
end

---deduplicate an array
---@param tbl table
---@return table
function utils.deduplicate(tbl)
  local res = {}
  local hash = {}
  for _, val in ipairs(tbl) do
    if not hash[val] then
      res[#res + 1] = val
      hash[val] = true
    end
  end
  return res
end

return utils
