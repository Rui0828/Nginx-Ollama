-- /etc/nginx/ollama/check_key.lua
-- 兩種權限：admin (全部操作) / inference (僅推論+唯讀資訊)

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

local ADMIN_KEYS     = read_keys("/etc/nginx/other_tools/ollama/admin_keys.txt")
local INFERENCE_KEYS = read_keys("/etc/nginx/other_tools/ollama/inference_keys.txt")

-- 管理操作 blocklist（inference key 不可使用）
local ADMIN_PATHS = {
  ["/api/pull"]   = true,
  ["/api/push"]   = true,
  ["/api/create"] = true,
  ["/api/copy"]   = true,
  ["/api/delete"] = true,
}

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

-- 判斷權限等級
local is_admin     = client_key and ADMIN_KEYS[client_key]
local is_inference = client_key and INFERENCE_KEYS[client_key]

-- 無效 key → 401
if not is_admin and not is_inference then
  ngx.status = ngx.HTTP_UNAUTHORIZED
  ngx.say("Unauthorized: Invalid or missing API Key")
  return ngx.exit(ngx.HTTP_UNAUTHORIZED)
end

-- inference key 嘗試管理操作 → 403
if is_inference and not is_admin then
  -- 取得去掉 prefix 後的實際路徑（Nginx location /ollama/ → proxy_pass 會 strip）
  -- ngx.var.uri 是完整 URI，需要去掉 location prefix 來比對
  local uri = ngx.var.uri
  -- 去掉 /ollama prefix（如果有的話）
  local api_path = uri:match("^/ollama(.*)$") or uri

  -- 檢查是否為管理路徑
  if ADMIN_PATHS[api_path] then
    ngx.status = ngx.HTTP_FORBIDDEN
    ngx.say("Forbidden: This API key does not have permission for model management operations")
    return ngx.exit(ngx.HTTP_FORBIDDEN)
  end

  -- 額外檢查 /api/blobs（路徑帶 digest 參數，用 prefix match）
  if api_path:match("^/api/blobs") then
    ngx.status = ngx.HTTP_FORBIDDEN
    ngx.say("Forbidden: This API key does not have permission for model management operations")
    return ngx.exit(ngx.HTTP_FORBIDDEN)
  end
end
