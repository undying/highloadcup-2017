
local storage_redis = {}
local redis = require('resty_redis')


function storage_redis.connect()
  local r = redis:new()
  local ok, err = r:connect(
    ngx.shared.storage_redis.options.host,
    ngx.shared.storage_redis.options.port)

  if not ok then
    ngx.log(ngx.STDERR, 'redis connection failed')
    return
  end

  return r
end


function storage_redis.set_timeout(connection)
  connection:set_keepalive(ngx.shared.storage_redis.options.keepalive)
end


return storage_redis

-- vi:syntax=lua
