-- openai_to_ollama.lua
local cjson = require("cjson.safe")

-- Read request body
ngx.req.read_body()
local body = ngx.req.get_body_data()
if not body then 
    return  -- No body, nothing to process
end

-- Decode the JSON body
local data, err = cjson.decode(body)
if not data then
    ngx.log(ngx.ERR, "Failed to decode JSON: ", err)
    return
end

-- Move control parameters to options structure
local opts = data.options or {}
local control_params = {
    "temperature", 
    "top_k", 
    "top_p", 
    "presence_penalty", 
    "frequency_penalty"
}

for _, param in ipairs(control_params) do
    if data[param] ~= nil then
        opts[param] = data[param]
        data[param] = nil
    end
end

-- Convert max_tokens to Ollama's num_predict
if data.max_tokens ~= nil then
    opts.num_predict = data.max_tokens
    data.max_tokens = nil
end

-- Handle stop parameter
if data.stop ~= nil then
    opts.stop = data.stop
    data.stop = nil
end

-- Update options in data and set new request body
data.options = opts
local new_body = cjson.encode(data)
ngx.req.set_body_data(new_body)
