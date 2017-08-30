
local item_loader = require('item_loader')

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
      ['compare'] = function(item_value, filter_value) return ((os.time() - item_value) / seconds_in_year) > filter_value  end,
      ['filter_field'] = 'birth_date',
      ['join_table'] = 'users',
      ['join_field'] = 'user'
    },
    ['toAge'] = {
      ['cast'] = tonumber,
      ['compare'] = function(item_value, filter_value) return ((os.time() - item_value) / seconds_in_year) < filter_value  end,
      ['filter_field'] = 'birth_date',
      ['join_table'] = 'users',
      ['join_field'] = 'user'
    },
    ['gender'] = {
      ['cast'] = function(g) if g == 'm' or g == 'f' then return g else return nil end end,
      ['compare'] = function(item_value, filter_value) return item_value == filter_value end,
      ['filter_field'] = 'gender',
      ['join_table'] = 'users',
      ['join_field'] = 'user'
    }
  }
}


function item_filter.validate(data_name)
  local valid_filters = {}
  local valid_filters_count = 0
  local passed_filters_count = 0

  for key, value in pairs(ngx.req.get_uri_args()) do
    if value ~= 'queryId' then
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
  end

  return valid_filters, valid_filters_count, passed_filters_count
end


function item_filter.match_filter(item_name, item, join_items, filter_name, filter_value)
  local filter = item_filters[item_name][filter_name]

  if not filter.join_field then
    return filter.compare(item[filter.filter_field], filter_value)
  end

  local join_item = join_items[filter.join_field]
  return filter.compare(join_item[filter.filter_field], filter_value)
end


function item_filter.match_filters(item_name, item, join_items, filters)
  local filters_matched = 0

  for filter_name, filter_value in pairs(filters) do
    if item_filter.match_filter(
        item_name,
        item,
        join_items,
        filter_name,
        filter_value) then
      filters_matched = filters_matched + 1
    end
  end

  return filters_matched
end


function item_filter.get_join_items(connection, item_name, item, filters)
  local join_items = {}
  local return_items = {}

  for filter_name, filter_value in pairs(filters) do
    local f = item_filters[item_name][filter_name]
    if f.join_table then
      if not join_items[f.join_field] then
        join_items[f.join_field] = f.join_table .. ':' .. item[f.join_field]
      end
    end
  end

  for name, key in pairs(join_items) do
    return_items[name] = item_loader.get(connection, key)
  end

  return return_items
end


return item_filter

-- vi:syntax=lua
