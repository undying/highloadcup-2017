
local item_format = {}

function item_format.round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

return item_format

-- vi:syntax=lua
