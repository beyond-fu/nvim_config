--- @class Help checking file information for neo-tree
M = {}

local SIZE_TYPES = { "", "K", "M", "G", "T", "P", "E", "Z" }
M.format_size = function(size)
  for k, v in ipairs(SIZE_TYPES) do
    if size < 1024.0 then
      if size > 9 then
        return string.format("%3d%s", size, v)
      else
        return string.format("%3.1f%s", size, v)
      end
    end
    size = size / 1024.0
  end
  return string.format("%.1f%s", size, "Y")
end

M.format_time = function(sec_time)
  local YEAR = os.date("%Y")
  if YEAR ~= os.date("%Y", sec_time) then
    return os.date("%b %d  %Y", sec_time)
  end
  return os.date("%b %d %H:%M", sec_time)
end

M.format_mode = function(mode, type)
  local mode_perm_map = {
    ["0"] = { "-", "-", "-" },
    ["1"] = { "-", "-", "x" },
    ["2"] = { "-", "w", "-" },
    ["3"] = { "-", "w", "x" },
    ["4"] = { "r", "-", "-" },
    ["5"] = { "r", "-", "x" },
    ["6"] = { "r", "w", "-" },
    ["7"] = { "r", "w", "x" },
  }
  local mode_type_map = {
    ["directory"] = "d",
    ["link"] = "l",
  }
  local owner, group, other = string.format("%3o", mode):match("(.)(.)(.)$")
  local stat = vim
    .iter({
      mode_type_map[type] or "-",
      mode_perm_map[owner],
      mode_perm_map[group],
      mode_perm_map[other],
    })
    :flatten()
    :totable()
  return table.concat(stat)
end

return M
