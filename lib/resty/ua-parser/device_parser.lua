local error = error
local ipairs = ipairs
local setmetatable = setmetatable

local DevicePattern = require('resty.ua-parser.device_pattern')

local OTHER = {
    ['family'] = 'Other'
}

local DeviceParser = {}

DeviceParser.__index = DeviceParser

setmetatable(DeviceParser, {
	__call = function(cls, ...)
		return cls.new(...)
	end
})

function DeviceParser.new(configs)
    local self = setmetatable({}, DeviceParser)

    local device_patterns = {}
    for i = 1, #configs do
        local config = configs[i]
        local regex = config["regex"]
        if not regex then
			error("Device is missing regex")
		end
        local p = DevicePattern.new(regex, config["regex_flag"], config["device_replacement"])
        device_patterns[#device_patterns + 1] = p
    end

    self.patterns = device_patterns

    return self
end

function DeviceParser:parse(user_agent_str)
    if not user_agent_str then
		return nil
	end

    for _, p in ipairs(self.patterns) do
        local device = p:match(user_agent_str)
        if device then
			return device
		end
    end

    return OTHER
end

return DeviceParser
