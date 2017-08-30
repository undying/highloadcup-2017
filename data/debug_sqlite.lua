
package.cpath = package.cpath .. ';/usr/local/lib/lua/5.1/?.so;/usr/local/openresty/lualib/?.so'

local cjson = require 'cjson'
local sqlite3 = require 'lsqlite3'


local db = sqlite3.open_memory()
-- local db = sqlite3.open('/tmp/db.sqlite3', sqlite3.OPEN_READWRITE + sqlite3.OPEN_CREATE + sqlite3.OPEN_SHAREDCACHE)

db:exec([=[
  CREATE TABLE users(id INTEGER UNIQUE, email TEXT, first_name TEXT, last_name TEXT, birth_date NUMERIC, gender TEXT);
  CREATE TABLE visits(id INTEGER UNIQUE, user INTEGER, mark INTEGER, visited_at NUMBER, location INTEGER);
  CREATE TABLE locations(id INTEGER UNIQUE, distance INTEGER, city TEXT, place TEXT, country TEXT);
]=])

local items_to_load = { 'users', 'visits', 'locations' }
for item_num = 1,3 do
  local item_name = items_to_load[item_num]

  for item_file in string.gmatch(io.popen('echo /tmp/data_unpack/' .. item_name .. '_*.json'):read(), "%S+") do
    print('Loading File: ' .. item_file)

    local file = io.open(item_file)
    local item_json = cjson.decode(file:read())

    local sql = ''
    local sql_prefix = 'INSERT INTO ' .. item_name
    local sql_columns = ''
    local sql_values = ''
    local item_num = 0

    local key_num = 0
    local comma = ''

    for index, item in pairs(item_json[item_name]) do
      sql = sql_prefix

      item_num = item_num + 1
      sql_values = ''
      comma = ''
      key_num = 0

      for key, value in pairs(item) do
        key_num = key_num + 1

        if key_num > 1 then
          comma = ','
        end

        if type(value) == 'number' then
          sql_values = sql_values .. comma .. value
        else
          sql_values = sql_values .. comma .. '"' .. value .. '"'
        end

        if item_num == 1 then
          sql_columns = sql_columns .. comma .. key
        end
      end

      sql = sql .. '(' .. sql_columns .. ') ' .. 'VALUES' .. ' (' .. sql_values .. ');'
      if db:exec(sql) > 0 then
        print(sql)
        print(db:error_message())
      end
    end
  end
end

