
local http_methods = require('http_methods')

local cjson = require('cjson')
local item_loader = require('item_loader')
local storage_redis = require('storage_redis')

local redis_client = storage_redis.connect()
local item_id = tonumber(ngx.var.id)

local redis_key = 'users:' .. item_id
local item = item_loader.get(redis_client, redis_key)


-- 404 if no such item
if not item then http_methods.http_not_found() end


-- 200 if request method == GET
if http_methods.is_method('GET') then
  storage_redis.set_keepalive(redis_client)
  http_methods.http_ok(cjson.encode(item))
end

-- 400 if method is not POST
if not http_methods.is_method('POST') then
  storage_redis.set_keepalive(redis_client)
  http_methods.http_bad_request()
end


local req_body = item_loader.get_req_body()
if not req_body then http_methods.http_bad_request() end


item_loader.item_update(item, req_body)
item_loader.set(redis_client, redis_key, item)

storage_redis.set_keepalive(redis_client)
http_methods.http_ok('{}')

-- vi:syntax=lua
