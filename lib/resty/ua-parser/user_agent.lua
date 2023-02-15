local setmetatable = setmetatable

local UserAgent = {}

UserAgent.__index = UserAgent

setmetatable(UserAgent, {
    __call = function(cls, ...)
        return cls.new(...)
    end
})

function UserAgent.new(family, major, minor, patch)
    local self = setmetatable({}, UserAgent)

    self.family = family
    self.major = major
    self.minor = minor
    self.patch = patch

    return self
end

return UserAgent