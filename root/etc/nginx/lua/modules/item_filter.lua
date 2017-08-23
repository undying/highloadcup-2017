
local item_filter = {}

local items = {
  ['visits'] = ngx.shared.visits,
  ['locations'] = ngx.shared.locations
}

local item_filters = {
  ['visits'] = {
    ['toDate'] = {
      ['cast'] = tonumber,
      ['compare'] = function(item_value, filter_value) return item_value < filter_value end,
      ['filter_field'] = 'visited_at',
      ['filter_table'] = 'visits'
    },
    ['fromDate'] = {
      ['cast'] = tonumber,
      ['compare'] = function(item_value, filter_value) return item_value > filter_value end,
      ['filter_field'] = 'visited_at',
      ['filter_table'] = 'visits'
    },
    ['country'] = {
      ['cast'] = false,
      ['compare'] = function(item_value, filter_value) return item_value == filter_value end,
      ['filter_field'] = 'country',
      ['filter_table'] = 'locations',
      ['filter_join_field'] = 'location'
    },
    ['toDistance'] = {
      ['cast'] = tonumber,
      ['compare'] = function(item_value, filter_value) return item_value < filter_value end,
      ['filter_field'] = 'distance',
      ['filter_table'] = 'locations',
      ['filter_join_field'] = 'location'
    }
  },
  ['locations'] = {}
}


function item_filter.validate(data_name, filters)
  local valid_filters = {}

  for key, value in pairs(filters) do
    local filter = item_filters[data_name][key]

    if filter then
      if filter.cast then
        valid_filters[key] = filter.cast(value)
      else
        valid_filters[key] = value
      end
    end
  end

  return valid_filters
end


function item_filter.match_filter(data_name, item_id, filter_name, filter_value)
  local item = items[data_name].values[item_id]
  local filter = item_filters[data_name][filter_name]

  if data_name == filter.filter_table then
    return filter.compare(item[filter.filter_field], filter_value)
  end

  local filter_table = items[filter.filter_table]
  local filter_item = filter_table.values[item[filter.filter_join_field]]

  return filter.compare(filter_item[filter.filter_field], filter_value)
end


return item_filter

-- vi:syntax=lua
