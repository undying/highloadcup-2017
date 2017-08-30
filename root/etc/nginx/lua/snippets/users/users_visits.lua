
local http_methods = require('http_methods')
if not http_methods.is_method('GET') then http_methods.http_bad_request() end


local cjson = require('cjson')
local item_loader = require('item_loader')
local storage_redis = require('storage_redis')
local storage_options = ngx.shared.storage_redis.options

local redis_client = storage_redis.connect(storage_options.host, storage_options.port)
local user_id = tonumber(ngx.var.id)

local redis_key = 'users:' .. user_id
local user = item_loader.get(redis_client, redis_key)


-- exit if no such item
if not user then http_methods.http_not_found() end


local redis_key = 'users_to_visits:' .. user_id
local visits_ids = item_loader.smembers(redis_client, redis_key)

if not visits_ids then
  cjson.encode_empty_table_as_object(false)
  http_methods.http_ok(cjson.encode({['visits'] = {}}))
end


local item_sort = require('item_sort')
local item_filter = require('item_filter')

local filters,
      filters_count,
      passed_filters_count = item_filter.validate('visits')

if filters_count ~= passed_filters_count then http_methods.http_bad_request() end

local visits = item_sort.sort('visits', item_loader.mget(redis_client, visits_ids))
if filters_count == 0 then http_methods.http_ok(cjson.encode({['visits'] = visits})) end


local return_visits = {}
for index, visit in pairs(visits) do
  local filters_matched = 0
  local join_items = item_filter.get_join_items(redis_client, 'visits', visit, filters)

  for filter_name, filter_value in pairs(filters) do
    if item_filter.match_filter('visits', visit, join_items, filter_name, filter_value) then
      filters_matched = filters_matched + 1
    end
  end

  if filters_matched == filters_count then
    local location = item_loader.item_try(connection, 'location', visit.location, join_items)
    table.insert(return_visits, {
      ['mark'] = visit.mark,
      ['visited_at'] = visit.visited_at,
      ['place'] = location.place
    })
  end
end


-- cjson.encode_empty_table_as_object(false)
ngx.say(cjson.encode({['visits'] = return_visits}))
redis_client:set_keepalive(ngx.shared.storage_redis.options.keepalive)

-- vi:syntax=lua
