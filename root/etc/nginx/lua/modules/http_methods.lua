
local http_methods = {}


function http_methods.http_not_found(body)
  if body then ngx.say(body) end
  ngx.exit(ngx.HTTP_NOT_FOUND)
end


function http_methods.http_bad_request(body)
  if body then ngx.say(body) end
  ngx.exit(ngx.HTTP_BAD_REQUEST)
end


function http_methods.http_ok(body, cb)
  if body then
    ngx.header.content_length = string.len(body)
    ngx.say(body)
  end

  if cb then cb() end
  ngx.exit(ngx.OK)
end


function http_methods.is_method(method)
  return ngx.req.get_method() == method
end


function http_methods.say(str)
  ngx.header.content_length = string.len(str)
  ngx.say(str)
end


return http_methods

-- vi:syntax=lua
