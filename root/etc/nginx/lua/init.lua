
-- global preload
local item_filter = require('item_filter')
local item_sort = require('item_sort')
--

local cjson = require('cjson')
local item_loader = require('item_loader')


local users = ngx.shared.users
local visits = ngx.shared.visits
local locations = ngx.shared.locations

local users_to_visits = ngx.shared.users_to_visits
users_to_visits[1] = {} -- if not declared import breaks down

local locations_to_visits = ngx.shared.locations_to_visits
locations_to_visits[1] = {} -- if not declared import breaks down


local items_dict = {}
items_dict.users = users
items_dict.visits = visits
items_dict.locations = locations

users.count = 0
users.values = {}

visits.count = 0
visits.values = {}

locations.count = 0
locations.values = {}


-- load jsons to memory as tables
local items_to_load = { 'users', 'visits', 'locations' }
for item_num = 1,3 do
  local item = items_to_load[item_num]

  for item_file in string.gmatch(io.popen('echo /tmp/data/' .. item .. '_*.json'):read(), "%S+") do
    ngx.log(ngx.STDERR, 'Loading File: ' .. item_file)

    local file = io.open(item_file)
    item_loader.load(items_dict[item], file, item)
  end
end


-- hashmap of user->visit list
for index, visit in pairs(visits.values) do
  local user = visit.user

  if users_to_visits[user] == nil then
    users_to_visits[user] = {}
  end

  table.insert(users_to_visits[user], visit.id)
end


-- hashmap of locations->visit
for index, visit in pairs(visits.values) do
  local location = visit.location

  if locations_to_visits[location] == nil then
    locations_to_visits[location] = {}
  end

  table.insert(locations_to_visits[location], visit.id)
end

-- vi:syntax=lua
