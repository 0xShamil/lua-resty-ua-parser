local setmetatable = setmetatable

local OS = {}

OS.__index = OS

setmetatable(OS, {
    __call = function(cls, ...)
        return cls.new(...)
    end
})

function OS.new(family, major, minor, patch, patch_minor)
    local self = setmetatable({}, OS)

    self.family = family
    self.major = major
    self.minor = minor
    self.patch = patch
    self.patch_minor = patch_minor

    return self
end

return OS