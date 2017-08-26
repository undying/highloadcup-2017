
local item_filter = {}

local seconds_in_year = 31557600

local items = {
  ['users'] = ngx.shared.users,
  ['visits'] = ngx.shared.visits,
  ['locations'] = ngx.shared.locations
}

local item_filters = {
  ['visits'] = {
    ['toDate'] = {
      ['cast'] = tonumber,
      ['compare'] = function(item_value, filter_value) return item_value < filter_value end,
      ['filter_field'] = 'visited_at',
    },
    ['fromDate'] = {
      ['cast'] = tonumber,
      ['compare'] = function(item_value, filter_value) return item_value > filter_value end,
      ['filter_field'] = 'visited_at',
    },
    ['country'] = {
      ['cast'] = false,
      ['compare'] = function(item_value, filter_value) return item_value == filter_value end,
      ['filter_field'] = 'country',
      ['join_table'] = 'locations',
      ['join_field'] = 'location'
    },
    ['toDistance'] = {
      ['cast'] = tonumber,
      ['compare'] = function(item_value, filter_value) return item_value < filter_value end,
      ['filter_field'] = 'distance',
      ['join_table'] = 'locations',
      ['join_field'] = 'location'
    }
  },

  ['locations'] = {
    ['fromDate'] = {
      ['cast'] = tonumber,
      ['compare'] = function(item_value, filter_value) return item_value > filter_value end,
      ['filter_field'] = 'visited_at',
    },
    ['toDate'] = {
      ['cast'] = tonumber,
      ['compare'] = function(item_value, filter_value) return item_value < filter_value end,
      ['filter_field'] = 'visited_at',
    },
    ['fromAge'] = {
      ['cast'] = tonumber,
      ['compare'] = function(item_value, filter_value) return item_value > (filter_value * seconds_in_year) end,
      ['filter_field'] = 'birth_date',
      ['join_table'] = 'users',
      ['join_field'] = 'user'
    },
    ['toAge'] = {
      ['cast'] = tonumber,
      ['compare'] = function(item_value, filter_value) return item_value < (filter_value * seconds_in_year) end,
      ['filter_field'] = 'birth_date',
      ['join_table'] = 'users',
      ['join_field'] = 'user'
    },
    ['gender'] = {
      ['cast'] = false,
      ['compare'] = function(item_value, filter_value) return item_value == filter_value end,
      ['filter_field'] = 'gender',
      ['join_table'] = 'users',
      ['join_field'] = 'user'
    }
  }
}


function item_filter.validate(data_name, filters)
  local valid_filters = {}
  local valid_filters_count = 0
  local passed_filters_count = 0

  for key, value in pairs(filters) do
    passed_filters_count = passed_filters_count + 1
    local filter = item_filters[data_name][key]

    if filter then
      if filter.cast then
        valid_filters[key] = filter.cast(value)
      else
        valid_filters[key] = value
      end

      if valid_filters[key] then
        valid_filters_count = valid_filters_count + 1
      end
    end
  end

  return valid_filters, valid_filters_count, passed_filters_count
end


function item_filter.match_filter(item, filter_table, filter_name, filter_value)
  local join_item = {}
  local filter = item_filters[filter_table][filter_name]

  if filter.join_table then
    join_item = items[filter.join_table].values[item[filter.join_field]]
  else
    join_item = item
  end

  return filter.compare(join_item[filter.filter_field], filter_value)
end


return item_filter

-- vi:syntax=lua
