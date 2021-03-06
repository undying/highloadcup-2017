
-- global preload
local http_methods = require('http_methods')

local item_counter = require('item_counter')
local item_filter = require('item_filter')
local item_format = require('item_format')
local item_loader = require('item_loader')
local item_sort = require('item_sort')

local storage_redis = require('storage_redis')
--

local cjson = require('cjson')
local redis = require('resty_redis')
--

-- redis connection options
ngx.shared.storage_redis.options = {}
ngx.shared.storage_redis.options.keepalive_idle = 600000
ngx.shared.storage_redis.options.keepalive_pool_size = 8192
ngx.shared.storage_redis.options.connections = { {'unix:/run/redis-master.sock'}, {'127.0.0.1', 16379} }
--

-- loading options.txt data
item_loader.load_options()
--

-- vi:syntax=lua
