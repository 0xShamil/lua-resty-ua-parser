local ipairs = ipairs
local setmetatable = setmetatable

local UAPattern = require('resty.ua-parser.ua_pattern')

local OTHER = {
    ['family'] = 'Other'
}

local UserAgentParser = {}

UserAgentParser.__index = UserAgentParser

function UserAgentParser.new(configs)
	local self = setmetatable({}, UserAgentParser)

	local ua_patterns = {}

	for i = 1, #configs do
		local config = configs[i]
		local regex = config['regex']
		local family_repl = config["family_replacement"]
        local v1_repl = config["v1_replacement"]
        local v2_repl = config["v2_replacement"]

		local ua_pattern = UAPattern.new(regex, family_repl, v1_repl, v2_repl)
		ua_patterns[#ua_patterns + 1] = ua_pattern
	end

	self.patterns = ua_patterns

    return self
end

function UserAgentParser:parse(ua_agent_str)
	if not ua_agent_str then
	  return nil
	end

	for _, p in ipairs(self.patterns) do
		local agent = p:match(ua_agent_str)
		if agent then
			return agent
		end
	end

	return OTHER
end

return UserAgentParser