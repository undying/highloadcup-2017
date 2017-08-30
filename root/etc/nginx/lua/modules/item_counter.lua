
local item_counter = {}
local item_format = require('item_format')


function item_counter.marks_avg(items)
  local mark_sum = 0
  local mark_count = 0

  for _, item in pairs(items) do
    mark_count = mark_count + 1
    mark_sum = mark_sum + item.mark
  end

  if mark_count > 0 then
    return item_format.round(mark_sum / mark_count, 5)
  else
    return 0
  end
end


return item_counter

-- vi:syntax=lua
