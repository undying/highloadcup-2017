
local storage_redis = {}
local redis = require('resty_redis')


function storage_redis.connect()
  local connections = {}

  for index, conn in pairs(ngx.shared.storage_redis.options.connections) do
    local r = redis:new()
    local ok, err = r:connect(unpack(conn))

    if not ok then
      ngx.log(ngx.STDERR, 'redis connection failed')
      return
    end

    table.insert(connections, r)
  end

  return connections
end


function storage_redis.chose(mode, connections)
  if mode == 'w' then
    if not connections[1] then return nil end
    return connections[1]
  end

  if not next(connections, 2) then return connections[1] end

  local to_chose_cnt = 0
  for index, connection in pairs(connections) do
    to_chose_cnt = to_chose_cnt + 1
  end

  return connections[(ngx.time() % to_chose_cnt) + 1]
end


function storage_redis.set_keepalive(connections)
  for _, connection in pairs(connections) do
    connection:set_keepalive(
      ngx.shared.storage_redis.options.keepalive_idle,
      ngx.shared.storage_redis.options.keepalive_pool
    )
  end
end


return storage_redis

-- vi:syntax=lua
