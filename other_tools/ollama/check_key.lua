-- /etc/nginx/ollama/check_key.lua
-- 一次性讀取 keys（production 建議放 shared_dict 或環境變數）

local function read_keys(path)
  local f, err = io.open(path, "r")
  if not f then
    ngx.log(ngx.ERR, "cannot open ", path, ": ", err)
    return {}
  end
  local t = {}
  for line in f:lines() do
    line = line:match("^%s*(.-)%s*$")  -- 去掉首尾空白
    if line ~= "" then t[line] = true end
  end
  f:close()
  return t
end

local KEYS = read_keys("/etc/nginx/other_tools/ollama/keys.txt")

-- 支援多種方式取 key：Header / Query / Authorization: Bearer
local headers = ngx.req.get_headers()
local auth_header = headers["authorization"]
local client_key =
    headers["x-api-key"] or
    headers["X-API-Key"] or
    ngx.var.arg_api_key

-- 如果還沒抓到，再試 Authorization: Bearer xxx
if not client_key and auth_header then
  local m = ngx.re.match(auth_header, "Bearer\\s+(.+)")
  if m then client_key = m[1] end
end

-- 預檢請求直接放行
if ngx.req.get_method() == "OPTIONS" then
  return
end

-- 檢查失敗就回 401
if not client_key or not KEYS[client_key] then
  ngx.status = ngx.HTTP_UNAUTHORIZED
  ngx.say("Unauthorized: Invalid or missing API Key")
  return ngx.exit(ngx.HTTP_UNAUTHORIZED)
end
