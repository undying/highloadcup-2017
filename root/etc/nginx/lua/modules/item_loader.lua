
local storage_redis = require('storage_redis')
local cjson = require('cjson')
local item_loader = {}

local item_relations = {
  ['visit'] = { 'user', 'location' }
}

local function check_result(res, err)
  if not res then
    ngx.log(ngx.STDERR, 'unable to get key from redis: ' .. err)
    return
  elseif res == ngx.null then
    return
  end

  return res
end


local function body_encode(body)
  if body then
    return cjson.encode(body)
  else
    return body
  end
end


local function body_decode(body)
  if body then
    return cjson.decode(body)
  else
    return body
  end
end


function item_loader.get(connections, key)
  local connection = storage_redis.chose('r', connections)
  local res, err = connection:get(key)
  return body_decode(check_result(res, err))
end


function item_loader.set(connections, key, value)
  local connection = storage_redis.chose('w', connections)
  local ok, err = connection:set(key, body_encode(value))
  return check_result(ok, err)
end


function item_loader.mget(connections, keys)
  local connection = storage_redis.chose('r', connections)
  local res, err = connection:mget(unpack(keys))

  if res and res ~= ngx.null then
    local result = {}

    for index, value in pairs(res) do
      if value and type(value) ~= 'userdata' then
        table.insert(result, body_decode(value))
      end
    end

    return result
  else
    return check_result(res, err)
  end
end


function item_loader.smembers(connections, key)
  local connection = storage_redis.chose('r', connections)
  local res, err = connection:smembers(key)
  return check_result(res, err)
end


function item_loader.sadd(connections, key, value)
  local connection = storage_redis.chose('w', connections)
  local res, err = connection:sadd(key, value)
  return check_result(res, err)
end


function item_loader.srem(connections, key, value)
  local connection = storage_redis.chose('w', connections)
  local res, err = connection:srem(key, value)
  return check_result(res, err)
end


function item_loader.item_try(connections, item_name, item_id, try_table)
  if try_table[item_name] then return try_table[item_name] end
  return item_loader.get(connections, item_name .. 's:' .. item_id)
end


function item_loader.item_update(item, update)
  for k, v in pairs(update) do
    item[k] = v
  end

  return item
end


function item_loader.update_relations(connections, item_name, item, update)
  if not item_relations[item_name] then
    return
  end

  for k, v in pairs(update) do
    for _, rel in pairs(item_relations[item_name]) do
      if k == rel then
        -- redis_key - locations_to_visits:<id>
        redis_key = rel .. 's_to_' .. item_name .. 's:' .. item[k]
        -- remove member from relation - srem(key, visits:<id>)
        item_loader.srem(connections, redis_key, item_name .. 's:' .. item.id)
        -- now generate new key for new relation
        redis_key = rel .. 's_to_' .. item_name .. 's:' .. v
        item_loader.sadd(connections, redis_key, item_name .. 's:' .. item.id)
      end
    end
  end
end


function item_loader.get_req_body()
  ngx.req.read_body() -- reading client body
  local body_data = ngx.req.get_body_data()

  if body_data then
    local return_data = body_decode(body_data)
    for k, v in pairs(return_data) do
      if not k or not v or type(v) == 'userdata' then
        return
      end
    end

    return return_data
  end
end


function item_loader.is_file_exists(file)
  local f = io.open(file)
  if f then
    io.close(f)
    return true
  else
    return false
  end
end


function item_loader.load_options()
  local options_files = {
    '/tmp/data/options.txt',
    '/tmp/data_unpack/options.txt'
  }

  for _, file in pairs(options_files) do
    ngx.log(ngx.STDERR, 'Trying to Load: ' .. file)

    if item_loader.is_file_exists(file) then
      ngx.log(ngx.STDERR, 'Loading: ' .. file)
      local line_num = 0

      for line in io.lines(file) do
        line_num = line_num + 1
        if line_num == 1 then
          ngx.shared.storage_redis.options.timestamp = tonumber(line)
        elseif line_num == 2 then
          ngx.shared.storage_redis.options.is_ratio = tonumber(line)
        else
          break
        end
      end
    end
  end
end


return item_loader

-- vi:syntax=lua
