local utils = require "utils"

local args = ngx.req.get_uri_args()
args["date"] = os.date("%Y-%m-%d",ngx.req.start_time())
local cjson = require "cjson"
local args_json = cjson.encode(args)

local red = utils:initRedis()

local ok, err = red:evalsha(ngx.var.redis_mobile_hash, 1, "args", args_json)
--Because we have some mobile devices with the old api, don't logging errors cause there are LOTS of from them!
if not ok then utils:emptyGif() end

ok, err = red:set_keepalive(10000, 1000)
if not ok then ngx.log(ngx.ERR, "Error setting redis keep alive from MOBILE " .. err) end
utils:emptyGif()
