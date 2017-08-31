
local storage_redis = {}
local redis = require('resty_redis')


function storage_redis.connect()
  local r = redis:new()
  local ok, err = r:connect(unpack(ngx.shared.storage_redis.options.connect))

  if not ok then
    ngx.log(ngx.STDERR, 'redis connection failed')
    return
  end

  return r
end


function storage_redis.set_keepalive(connection)
  connection:set_keepalive(
  ngx.shared.storage_redis.options.keepalive_idle,
  ngx.shared.storage_redis.options.keepalive_pool)
end


return storage_redis

-- vi:syntax=lua
