
local item_sort = {}
local item_sorters = {
  ['visits'] = function(a, b) return a.visited_at < b.visited_at end
}


function item_sort.sort(data_name, data_table)
  table.sort(data_table, item_sorters[data_name])
  return data_table
end


return item_sort

-- vi:syntax=lua
