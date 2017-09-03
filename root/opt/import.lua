
package.cpath = package.cpath .. ';/usr/local/lib/lua/5.1/?.so'
package.path = package.path .. ';/usr/local/share/lua/5.1/?.lua'

local cjson = require 'cjson'
local redis = require 'redis'

local buffer_limit = 2500

local is_visits = false
local item_name = ''
local item_list = { 'visits', 'locations', 'users' }

local redis_client = redis.connect('127.0.0.1', 6379)

function pipeline_sadd(redis_client, buffer)
  redis_client:pipeline(function(r)
    for _, line in pairs(buffer) do
      for k, v in pairs(line) do
        r:sadd(k, v)
      end
    end
  end)
end

function pipeline_set(redis_client, buffer)
  redis_client:pipeline(function(r)
    for key, value in pairs(buffer) do
      r:set(key, value)
    end
  end)
end


for index, item_file in ipairs(arg) do
  item_name = ''
  is_visits = false

  for _, iname in pairs(item_list) do
    if string.match(item_file, iname) then
      item_name = iname
    end
  end

  if item_name ~= '' then
    print('Loading File: ' .. item_file)

    if item_name == 'visits' then is_visits = true end

    local buffer_set = {}
    local buffer_set_len = 0

    local buffer_sadd = {}
    local buffer_sadd_len = 0

    local file = io.open(item_file)
    -- local item_json = cjson.decode(file:read())

    -- for index, item in pairs(item_json[item_name]) do
    for index, item in pairs(cjson.decode(file:read())[item_name]) do
      buffer_set[item_name .. ':' .. item.id] = cjson.encode(item)
      buffer_set_len = buffer_set_len + 1

      -- if buffer filled - purge it
      if buffer_set_len > buffer_limit then
        pipeline_set(redis_client, buffer_set)

        buffer_set_len = 0
        buffer_set = {}
      end

      if is_visits then
        table.insert(buffer_sadd, {['users_to_visits:' .. item.user] = 'visits:' .. item.id})
        table.insert(buffer_sadd, {['locations_to_visits:' .. item.location] = 'visits:' .. item.id})
        buffer_sadd_len = buffer_sadd_len + 2
        if buffer_sadd_len > buffer_limit then
          pipeline_sadd(redis_client, buffer_sadd)

          buffer_sadd_len = 0
          buffer_sadd = {}
        end
      end
    end

    -- buffer cleanup
    if buffer_set_len > 0 then
      pipeline_set(redis_client, buffer_set)
    end

    if buffer_sadd_len > 0 then
      pipeline_sadd(redis_client, buffer_sadd)
    end
  end
end

