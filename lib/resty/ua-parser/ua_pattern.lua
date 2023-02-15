local error = error
local assert = assert
local setmetatable = setmetatable

local C = require('ffi').C
local core_base = require("resty.core.base")
local core_regex = require("resty.core.regex")
local new_tab = core_base.new_tab
local collect_captures = core_regex.collect_captures

local EMPTY_STR = ''
local FAMILY = 'family'
local MAJOR = 'major'
local MINOR = 'minor'
local PATCH = 'patch'

local UAPattern = {}

UAPattern.__index = UAPattern

function UAPattern.new(pattern, family_replacement, v1_replacement, v2_replacement)
    local self = setmetatable({}, UAPattern)

    local compiled, err, flags = core_regex.re_match_compile(pattern, 'joxi')
    assert(compiled, err)

    local p = {
        regex = compiled,
        flags = flags
    }

    self.pattern = p
    self.flags = flags
    self.family_replacement = family_replacement
    self.v1_replacement = v1_replacement
    self.v2_replacement = v2_replacement

    return self
end

function UAPattern:match(ua_agent_str)
    local family, v1, v2, v3

    local pattern = self.pattern
    local regex = pattern.regex

    local res = new_tab(regex.ncaptures, regex.name_count)
    if not ua_agent_str then
        return false, res
    end

    local rc = C.ngx_http_lua_ffi_exec_regex(regex, pattern.flags, ua_agent_str, #ua_agent_str, 0)

    if rc > 0 then
        local m = collect_captures(regex, rc, ua_agent_str, pattern.flags, res)

        local group_count = #m - 1 -- m[0] holds the whole substring being matched

        local family_replacement = self.family_replacement
        if family_replacement then
            if family_replacement:find("$1") and group_count >= 1 and m[1] then
                family = family_replacement:gsub("$1", m[1])
            else
                family = family_replacement
            end
        elseif group_count >= 1 then
            family = m[1]
        end

        local v1_replacement = self.v1_replacement
        if v1_replacement then
            v1 = v1_replacement
        elseif group_count >= 2 then
            local group2 = m[2]
            if group2 and group2 ~= EMPTY_STR then
                v1 = group2
            end
        end

        local v2_replacement = self.v2_replacement

        if v2_replacement then
            v2 = v2_replacement
        elseif group_count >= 3 then
            local group3 = m[3]
            if group3 and group3 ~= EMPTY_STR then
                v2 = group3
            end
            if group_count >= 4 then
                local group4 = m[4]
                if group4 and group4 ~= EMPTY_STR then
                    v3 = group4
                end
            end
        end
    end

    if not family then
        return nil
    end

    return {
        [FAMILY] = family,
        [MAJOR] = v1,
        [MINOR] = v2,
        [PATCH] = v3
    }
end

return UAPattern