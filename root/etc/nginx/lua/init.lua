
-- global preload
local item_loader = require('item_loader')
local item_filter = require('item_filter')
local item_format = require('item_format')
local item_sort = require('item_sort')

local storage_redis = require('storage_redis')
--

local cjson = require('cjson')
local redis = require('resty_redis')
--

-- redis connection options
ngx.shared.storage_redis.options = {}
ngx.shared.storage_redis.options.host = '127.0.0.1'
ngx.shared.storage_redis.options.port = 6379
ngx.shared.storage_redis.options.keepalive = 600000
--

-- vi:syntax=lua
