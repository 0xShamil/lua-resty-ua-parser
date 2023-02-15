local error = error
local assert = assert
local tonumber = tonumber
local setmetatable = setmetatable
local string_sub = string.sub

local ngx_re_gsub = ngx.re.gsub

local C = require('ffi').C
local core_base = require("resty.core.base")
local core_regex = require("resty.core.regex")
local new_tab = core_base.new_tab

local collect_captures = core_regex.collect_captures
local function compile_regex(pattern)
    local compiled, err, flags = core_regex.re_match_compile(pattern, 'joxi')
    assert(compiled, err)
    return compiled, flags
end

local CG_ONE = [[($1)]]

local FAMILY = 'family'
local MAJOR = 'major'
local MINOR = 'minor'
local PATCH = 'patch'
local PATCH_MINOR = 'patch_minor'

local OSPattern = {}
OSPattern.__index = OSPattern

function OSPattern.new(pattern, os_replacement, v1_replacement, v2_replacement,
                       v3_replacement)
    local self = setmetatable({}, OSPattern)

    local compiled, flags = compile_regex(pattern)
    local p = {
        regex = compiled,
        flags = flags
    }
    self.pattern = p

    self.flags = flags
    self.os_replacement = os_replacement
    self.v1_replacement = v1_replacement
    self.v2_replacement = v2_replacement
    self.v3_replacement = v3_replacement

    return self
end

local function get_replacement(replacement, matches)
    if string_sub(replacement, 1, 1) == "$" then
        local group = tonumber(string_sub(replacement, 2))
        return matches[group]
    else
        return replacement
    end
end

function OSPattern:match(user_agent_str)
    local family, v1, v2, v3, v4

    local pattern = self.pattern
    local regex = pattern.regex
    local res = new_tab(regex.ncaptures, regex.name_count)
    if not user_agent_str then
        return false, res
    end
    local rc = C.ngx_http_lua_ffi_exec_regex(regex, pattern.flags, user_agent_str, #user_agent_str, 0)

    if rc > 0 then
        local m = collect_captures(regex, rc, user_agent_str, pattern.flags, res)

        local group_count = #m - 1

        if self.os_replacement then
            if group_count >= 1 then
                local repl = ngx_re_gsub(self.os_replacement, CG_ONE, m[1])
                if repl then
                    family = repl
                end
            else
                family = self.os_replacement
            end
        elseif group_count >= 1 then
            family = m[1]
        end

        if self.v1_replacement then
            v1 = get_replacement(self.v1_replacement, m)
        elseif group_count >= 2 then
            v1 = m[2]
        end

        if self.v2_replacement then
            v2 = get_replacement(self.v2_replacement, m)
        elseif group_count >= 3 then
            v2 = m[3]
        end

        if self.v3_replacement ~= nil then
            v3 = get_replacement(self.v3_replacement, m)
        elseif group_count >= 4 then
            v3 = m[4]
        end

        if group_count >= 5 then
            v4 = m[5]
        end
    end

    if family == nil then
        return nil
    else
        return {
            [FAMILY] = family,
            [MAJOR] = v1,
            [MINOR] = v2,
            [PATCH] = v3,
            [PATCH_MINOR] = v4
        }
    end
end

return OSPattern