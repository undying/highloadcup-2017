
local http_methods = require('http_methods')
if not http_methods.is_method('POST') then http_methods.http_bad_request() end


local cjson = require('cjson')
local item_loader = require('item_loader')
local storage_redis = require('storage_redis')

local redis_client = storage_redis.connect()

local req_body = item_loader.get_req_body()
if not req_body then http_methods.http_bad_request() end

local redis_key = 'locations:' .. req_body.id
item_loader.set(redis_client, redis_key, req_body)


http_methods.http_ok('{}')
storage_redis.set_timeout(redis_client)


-- vi:syntax=lua
