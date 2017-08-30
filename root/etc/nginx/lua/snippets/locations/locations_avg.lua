
local http_methods = require('http_methods')
if not http_methods.is_method('GET') then http_methods.http_bad_request() end

local cjson = require('cjson')
local item_loader = require('item_loader')

local storage_redis = require('storage_redis')
local redis_client = storage_redis.connect()

local item_id = tonumber(ngx.var.id)


local item_counter = require('item_counter')
local item_filter = require('item_filter')

local filters,
      filters_count,
      passed_filters_count = item_filter.validate('locations')

-- 400 if filters are invalid
if filters_count ~= passed_filters_count then http_methods.http_bad_request() end


local redis_key = 'locations:' .. item_id
local item = item_loader.get(redis_client, redis_key)

-- 404 if item not found
if not item then http_methods.http_not_found() end


local redis_key = 'locations_to_visits:' .. item.id
local visits_ids = item_loader.smembers(redis_client, redis_key)

if not visits_ids or next(visits_ids) == nil then
  http_methods.http_ok('{"avg":0}')
end


local visits = item_loader.mget(redis_client, visits_ids)
if filters_count == 0 then
  http_methods.http_ok(cjson.encode({['avg'] = item_counter.marks_avg(visits)}))
end


local return_visits = {}
for index, visit in pairs(visits) do
  local join_items = item_filter.get_join_items(redis_client, 'locations', visit, filters)
  local filters_matched = item_filter.match_filters('locations', visit, join_items, filters)

  if filters_matched == filters_count then
    table.insert(return_visits, visit)
  end
end

ngx.say(cjson.encode({['avg'] = item_counter.marks_avg(return_visits)}))
storage_redis.set_timeout(redis_client)

-- vi:syntax=lua
