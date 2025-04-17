-- /etc/nginx/ollama/check_key.lua
-- 一次性讀取 keys（production 建議放 shared_dict 或 env 變數才不用每次 I/O）

local function read_keys(path)
  local f, err = io.open(path, "r")
  if not f then
      ngx.log(ngx.ERR, "cannot open ", path, ": ", err)
      return {}
  end
  local t = {}
  for line in f:lines() do
      line = line:match("^%s*(.-)%s*$")  -- 去掉首尾空白及 \r
      if line ~= "" then t[line] = true end
  end
  f:close()
  return t
end

local KEYS = read_keys("/etc/nginx/other_tools/ollama/keys.txt")


-- 允許從 header 或 query 取 key，大小寫不敏感
local headers = ngx.req.get_headers()
local client_key = headers["x-api-key"]           -- OpenResty 8 成以上都給小寫
                or headers["X-API-Key"]         -- 保險再試一次原大小寫
                or ngx.var.arg_api_key          -- 也允許 ?api_key=xxx

-- 預檢請求直接放行
if ngx.req.get_method() == "OPTIONS" then
  return
end

-- 檢查失敗就回 401 比 403 更語意化 & 少量 log
if not client_key or not KEYS[client_key] then
  ngx.status = ngx.HTTP_UNAUTHORIZED
  ngx.say("Unauthorized: Invalid or missing API Key")
  return ngx.exit(ngx.HTTP_UNAUTHORIZED)
end
