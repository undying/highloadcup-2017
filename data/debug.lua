
package.cpath = package.cpath .. ';/usr/local/lib/lua/5.1/?.so'
package.path = package.path .. ';/usr/local/share/lua/5.1/?.ljbc'

local JSON = require 'JSON'
local cjson = require 'cjson'
local redis = require 'redis'
local inspect = require 'inspect'

local redis_client = redis.connect('127.0.0.1', 6379)

local item_name = ''
local item_list = { 'visits', 'locations', 'users' }

for index, item_file in ipairs(arg) do
  item_name = ''

  for _, iname in pairs(item_list) do
    if string.match(item_file, iname) then
      item_name = iname
    end
  end

  if item_name ~= '' then
    print('Loading File: ' .. item_file)

    local file = io.open(item_file)
    local item_json = JSON:decode(file:read())

    -- for index, item in pairs(item_json[item_name]) do
    --   redis_client:set(item_name .. ':' .. item.id, cjson.encode(item))
    -- end
  end
end

