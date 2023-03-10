local error = error
local ipairs = ipairs
local setmetatable = setmetatable

local OSPattern = require('resty.ua-parser.os_pattern')

local OTHER = {
    ['family'] = 'Other'
}

local OSParser = {}

OSParser.__index = OSParser

function OSParser.new(configs)
    local self = setmetatable({}, OSParser)

    local os_patterns = {}
    for i = 1, #configs do
        local config = configs[i]
        local regex = config["regex"]
        if not regex then
			error("OS is missing regex")
		end
        local p = OSPattern.new(regex, config["os_replacement"],
                                config["os_v1_replacement"],
                                config["os_v2_replacement"],
                                config["os_v3_replacement"])
        os_patterns[#os_patterns + 1] = p
    end

    self.patterns = os_patterns

    return self
end

function OSParser:parse(user_agent_str)
    if not user_agent_str then
		return nil
	end

    for _, p in ipairs(self.patterns) do
        local os = p:match(user_agent_str)
        if os then
			return os
		end
    end

    return OTHER
end

return OSParser
