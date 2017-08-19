
package.cpath = package.cpath .. ';/usr/local/openresty/lualib/?.so'

local cjson = require 'cjson'
local users = {}

users.count = 0
users.values = {}

file = io.open('/tmp/data/users_1.json')
if not file then
  print('unable to open file')
  exit()
end

users_json = cjson.decode(file:read())
for index, user in ipairs(users_json["users"]) do
  users.values[index] = user
  users.count = users.count + 1
end

print('count: ' .. users.count)

