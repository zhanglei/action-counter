local utils = require "utils"
local cjson = require "cjson"

ngx.header["Cache-Control"] = "no-cache"
local args = utils:normalizeKeys( ngx.req.get_query_args() )
local red = utils:initRedis()
local key = args["key"]
local attributes = args["attr"]
local from = args["from"] or 0
local to = args["to"] or -1

function logAndReturnError(err)
  ngx.log(ngx.ERR, err)
  err_response = cjson.encode( { error = err } )
  return err_response
  -- ngx.say(err_response)
end

function determineDataType(key)
    local key_type
    local err
    if attributes then
		key_type = "hash"
	elseif args["from"] or args["to"] then
		key_type = "zset"
	else
		key_type, err = red:type(key)
	end

	return key_type, err
end


function getValues(key, attributes)
	local value
	local err
	local key_type, err = determineDataType(key)
	if key_type == "hash" then
		if attributes then
			if type(attributes) == "table" then
				values, err = red:hmget(key, unpack(attributes))
				if values then 
					value = {}
					for i = 1, #attributes, 1  do
						table.insert(value, attributes[i])
						table.insert(value, values[i])
					end
				end
			else
				value, err = red:hget(key, attributes)
			end
		else
			value, err = red:hgetall(key)
		end
	elseif key_type == "zset" then
		value, err = red:zrevrange(key, from, to, "withscores")
	elseif key_type == "string" then
		value, err = red:get(key)
	else
		err = "No such key in DB"
	end

	if not value and err then
		if key then -- PATCH until igor's fix
			ngx.log(ngx.ERR, "Failed to get value from Redis for key '" .. key .. "': " .. err)
			local err_response = { error = err }
			return err_response
		else
			return { error = err }
		end
	elseif type(value) == "table" then
		value = red:array_to_hash(value)  -- array_to_hash is an auxalrity function, written in lua, its part of the redis package, and does not actually run on the redis server
		return value
	else
		return value
	end
end

local response
if type(key) == "table" then
	response = {}
	for i, curKey in ipairs(key) do
		response[curKey] = getValues(curKey, attributes)
	end
else
	response = getValues(key, attributes)
end

local req_err = false  

if type(response) == "table" then
	if response["error"] then req_err = true end
	response = cjson.encode(response)
end

if not req_err then
	ok, err = red:set_keepalive(10000, 100)
	if not ok then ngx.log(ngx.ERR, err) end
end

ngx.say(response)
