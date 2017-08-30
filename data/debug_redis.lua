
package.cpath = package.cpath .. ';/usr/local/lib/lua/5.1/?.so'
package.path = package.path .. ';/usr/local/share/lua/5.1/?.lua'

local cjson = require 'cjson'
local redis = require 'redis'

local redis_client = redis.connect('127.0.0.1', 6379)

local items_to_load = { 'users', 'visits', 'locations' }
for item_num = 1,3 do
  local item_name = items_to_load[item_num]

  for item_file in string.gmatch(io.popen('echo /tmp/data_unpack/' .. item_name .. '_*.json'):read(), "%S+") do
    print('Loading File: ' .. item_file)

    local file = io.open(item_file)
    local item_json = cjson.decode(file:read())

    for index, item in pairs(item_json[item_name]) do
      redis_client:set(item_name .. ':' .. item.id, cjson.encode(item))
    end
  end
end

