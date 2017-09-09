
local storage_redis = {}
local redis = require('resty_redis')


function storage_redis.connect()
  local connections = {}

  for index, conn in pairs(ngx.shared.storage_redis.options.connections) do

    local tries = 7
    local r = redis:new()

    repeat
      local ok, err = r:connect(unpack(conn))

      if err then
        ngx.log(ngx.STDERR, 'redis connection failed, tries left: ' .. tries .. ', error: ' .. err)
      end

      if tries <= 0 then break end
      tries = tries - 1
    until(ok)

    table.insert(connections, r)
  end

  return connections
end


function storage_redis.chose(mode, connections)
  if not next(connections) then return nil end
  if not connections[2] then return connections[1] end
  if mode == 'w' then return connections[1] end

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
      ngx.shared.storage_redis.options.keepalive_pool_size
    )
  end
end


return storage_redis

-- vi:syntax=lua
