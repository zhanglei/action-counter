local redis = require "resty.redis"
local utils = {}

function utils:getCountry()
  local country = geodb:query_by_addr(ngx.var.remote_addr, "id")
  return geoip.code_by_id(country) or "--"
end

function utils:normalizeKeys(tbl)
  local normalized = {}
  for k, v in pairs(tbl) do
    local key = k:gsub("amp;", "")
    local value = v
    if key:match("[[]]") then
      key = key:gsub("[[]]", "")
      if type(value) ~= "table" then
        value = { v }
      end
    end

    if type(value) == "table" then
      for key, vl in pairs(value) do
        value[key] = vl:gsub("?", "")
      end
    else
      value = value:gsub("?", "")
    end

    normalized[key] = value
  end
  return normalized
end

function utils:initRedis()
  local red = redis:new()
  red:set_timeout(5000) -- 3 sec
  local ok, err = red:connect("unix:/var/run/redis/redis.sock")
  if not ok then utils:logErrorAndExit("Error connecting to redis: ".. err) end
  return red
end

function utils:logErrorAndExit(err)
   ngx.log(ngx.ERR, err)
   utils:emptyGif()
end


function utils:emptyGif()
  ngx.exec('/_.gif')
end

return utils
