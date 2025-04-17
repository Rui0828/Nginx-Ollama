-- /etc/nginx/ollama/check_key.lua
local function read_keys()
    local file = io.open("/etc/nginx/ollama/keys.txt", "r")
    if not file then
      ngx.log(ngx.ERR, "Failed to open keys.txt")
      return {}
    end
  
    local keys = {}
    for line in file:lines() do
      keys[line] = true
    end
    file:close()
    return keys
  end
  
  local keys = read_keys()
  local client_key = ngx.req.get_headers()["X-API-Key"]
  
  if not client_key or not keys[client_key] then
    ngx.status = 403
    ngx.say("Forbidden: Invalid API Key")
    return ngx.exit(403)
  end
  