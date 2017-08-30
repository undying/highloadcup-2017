
local http_methods = require('http_methods')

local cjson = require('cjson')
local item_loader = require('item_loader')
local storage_redis = require('storage_redis')

local redis_client = storage_redis.connect()
local user_id = tonumber(ngx.var.id)

local redis_key = 'users:' .. user_id
local user = item_loader.get(redis_client, redis_key)


-- 404 if no such item
if not user then http_methods.http_not_found() end


-- 200 if request method == GET
if http_methods.is_method('GET') then
  http_methods.http_ok(cjson.encode(user))
end

-- 400 if method is not POST
if not http_methods.is_method('POST') then
  http_methods.http_bad_request()
end


local req_body = item_loader.get_req_body()
if not req_body then http_methods.http_bad_request() end


item_loader.item_update(user, req_body)
item_loader.set(redis_client, redis_key, user)

ngx.say('{}')
storage_redis.set_timeout(redis_client)

-- vi:syntax=lua
