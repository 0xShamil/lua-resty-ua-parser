local ipairs = ipairs
local tonumber = tonumber
local setmetatable = setmetatable

local string_find = string.find
local string_sub = string.sub

local ngx_re_match = ngx.re.match
local ngx_re_sub = ngx.re.sub

local FAMILY = 'family'

local DevicePattern = {}

DevicePattern.__index = DevicePattern

setmetatable(DevicePattern, {
    __call = function(cls, ...)
        return cls.new(...)
    end
})

function DevicePattern.new(pattern, regex_flag, device_replacement)
    local self = setmetatable({}, DevicePattern)

    self.pattern = pattern
    self.flags = ('i' == regex_flag) and 'joi' or 'jo'
    self.device_replacement = device_replacement

    return self
end

function DevicePattern:match(user_agent_str)
    local matches = ngx_re_match(user_agent_str, self.pattern, 'jo')
    if matches == nil then
        return nil
    end

    local device = nil
    local device_replacement = self.device_replacement
    if device_replacement then
        if string_find(device_replacement, "$") then
            device = device_replacement

            local substitutions = {}
            do
                local i = 1
                local j = 0
                while true do
                    i, j = string_find(device_replacement, "%$%d", i)
                    if i == nil then
                        break
                    end
                    substitutions[#substitutions + 1] = string_sub(device_replacement, i, j)
                    i = j + 1
                end
            end

            for _, substitution in ipairs(substitutions) do
                local i = tonumber(string_sub(substitution, 2))
                local replacement = (#matches >= i and matches[i] ~= nil) and matches[i] or ""
                device = ngx_re_sub(device, "\\" .. substitution, replacement)
            end
            
            device = device:match'^()%s*$' and '' or device:match'^%s*(.*%S)'
        else
            device = device_replacement
        end
    elseif #matches > 0 then
        device = matches[1]
    end

    return {
        [FAMILY] = device
    }
end

return DevicePattern

