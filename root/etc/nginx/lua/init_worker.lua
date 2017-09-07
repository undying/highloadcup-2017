
collectgarbage('stop')
local _, err = ngx.timer.every(1, collectgarbage('step'))

if err then
  ngx.log(ngx.STDERR, 'timer failed: ' .. err)
end

-- vi:syntax=lua
