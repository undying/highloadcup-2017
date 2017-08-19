
local cjson = require('cjson')
local item_loader = {}


function item_loader.load(load_to, file, item_name)
  users_json = cjson.decode(file:read())
  for index, item in ipairs(users_json[item_name]) do
    load_to.values[item.id] = item
    load_to.count = load_to.count + 1
  end

  return load_to
end


return item_loader

-- vi:syntax=lua
