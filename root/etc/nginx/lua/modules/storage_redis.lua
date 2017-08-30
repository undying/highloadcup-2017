
local storage_redis = {}
local redis = require('resty_redis')


function storage_redis.connect(host, port)
  local r = redis:new()
  local ok, err = r:connect(host, port)

  if not ok then
    ngx.log(ngx.STDERR, 'redis connection failed')
    return
  end

  return r
end


return storage_redis

-- vi:syntax=lua
