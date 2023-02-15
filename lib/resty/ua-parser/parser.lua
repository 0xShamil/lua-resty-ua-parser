local cjson = require('cjson.safe')

local UserAgentParser = require('resty.ua-parser.ua_agent_parser')
local OSParser = require('resty.ua-parser.os_parser')
local DeviceParser = require('resty.ua-parser.device_parser')

local ua_regexes = require('resty.ua-parser.data.regexes_json')

local ua_parser, os_parser, device_parser
do
    local regex_config = cjson.decode(ua_regexes)
    ua_parser = UserAgentParser.new(regex_config["user_agent_parsers"])
    os_parser = OSParser.new(regex_config["os_parsers"])
    device_parser = DeviceParser.new(regex_config["device_parsers"])
end

local _M = {}

function _M.parse(user_agent_str)
    local ua = ua_parser:parse(user_agent_str)
    local os = os_parser:parse(user_agent_str)
    local device = device_parser:parse(user_agent_str)

    return {
        ua = ua,
        os = os,
        device = device
    }
end

return _M
