
local cjson = require('cjson')
local item_loader = {}


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


function item_loader.get(connection, key)
  local res, err = connection:get(key)
  return body_decode(check_result(res, err))
end


function item_loader.mget(connection, keys)
  local res, err = connection:mget(unpack(keys))
  if res and res ~= ngx.null then
    local result = {}
    for _, value in pairs(res) do
      table.insert(result, body_decode(value))
    end

    return result
  else
    return check_result(res, err)
  end
end


function item_loader.smembers(connection, key)
  local res, err = connection:smembers(key)
  return check_result(res, err)
end


function item_loader.item_try(connection, item_name, item_id, try_table)
  if try_table[item_name] then
    return try_table[item_name]
  end

  local res, err = connection:get(item_name .. ':' .. item_id)
  return body_decode(check_result(res, err))
end

return item_loader

-- vi:syntax=lua
