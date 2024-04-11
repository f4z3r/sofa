local io = require("io")
local os = require("os")

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
---@return string
function utils.run(cmd)
  local ph = assert(io.popen(cmd, "r"))
  local out = ph:read("*a")
  ph:close()
  return out
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
