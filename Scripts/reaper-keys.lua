-- @description reaper-keys
-- @version 1.0.0
-- @author gwatcha
-- @author myrrc
-- @description
--   Vim-like keybindings for Reaper -- map keystroke combinations to actions.
-- @links
--   GitHub repository https://github.com/myrrc/reaper-keys
-- @provides
--   definitions/*
--   internal/*

local defs = require "../internal/install/defs"
--local root_dir_path = debug.getinfo(1).source:match("@?(.*/)")
local root_dir_path = "."
local key_script_dir = 'key_scripts/'
local keymap_path = 'reaper-keys.ReaperKeyMap'

local mods_with_shift = { S = true, MS = true, CS = true, CMS = true }

local function format_shifted_letter(mod, letter)
    local key = letter:upper()

    local mods_excluding_shift = mod:gsub("S", "")
    if mods_excluding_shift ~= '' then
        key = "<" .. mods_excluding_shift .. "-" .. key .. ">"
    end

    return key, "(" .. mod .. "-" .. letter .. ")"
end

local function format_modded_key(key, key_name, key_group, mod)
    if mods_with_shift[mod] and key_group == "letters" then
        return format_shifted_letter(mod, key)
    end

    if key:match("<(.*)>") ~= nil then
        local key_without_cases = key:sub(2, -2)
        return
            "<" .. mod .. "-" .. key_without_cases .. ">",
            "(" .. mod .. "-" .. key_without_cases .. ")"
    else
        return
            "<" .. mod .. "-" .. key .. ">",
            "(" .. mod .. "-" .. key_name .. ")"
    end
end

local function key_script(key, context)
    key = key:gsub("\\", "\\\\"):gsub("'", "\\'")
    return
        "package.path = package.path..';'.." ..
        "debug.getinfo(1,'S').source:match[[([^@]*reaper.keys[^\\\\/]*[\\\\/])]]" ..
        "..'?.lua';" ..
        "require'internal.reaper-keys'{key='" .. key .. "', context='" .. context .. "'}"
end

local function keymap_write_key(key_type_id, key_id, context_id, script_id)
    io.open(keymap_path, "a"):write(
        "KEY " .. key_type_id .. " " .. key_id .. " " .. script_id .. " " .. context_id .. "\n")
end

local function keymap_scr(key, context_id, script_id, key_script_path)
    local quote = (key == '"') and "'" or '"'
    return
        "SCR 4 " .. context_id .. " " ..
        quote .. script_id .. quote .. " " ..
        quote .. "[reaper-keys] [key_press] [" .. key .. "]" .. quote .. " " ..
        key_script_path .. "\n"
end

local function gen_key(key_type_id, key, key_name, key_id, context, context_id)
    local script_path = key_script_dir .. context .. "_" .. key_name .. ".lua"
    io.open(script_path, "w"):write(key_script(key, context))

    local script_id = "_reaper_keys_" .. context .. "_" .. key
    local reaper_script_path = './' .. root_dir_path .. script_path

    io.open(keymap_path, "a"):write(keymap_scr(key, context_id, script_id, reaper_script_path))
    keymap_write_key(key_type_id, key_id, context_id, script_id)
end

local function gen_modified_keys(key, key_id, key_name, key_group, context, context_id)
    for mod, mod_id in pairs(defs.mods) do
        local has_shift = mods_with_shift[mod]

        if not (key_group == "shifted" and has_shift) then
            local shifted_key = defs.shift_map[key]

            if shifted_key ~= nil and has_shift then
                mod = mod:gsub("([CM]+)S", "")
                local modded_key = shifted_key
                if mod then
                    modded_key, _ = format_modded_key(shifted_key, shifted_key, 'shifted', mod)
                end

                if defs.mod_decremented_keys[key] ~= nil then
                    mod_id = mod_id - 1
                end

                local reaper_key_script_id = "_reaper_keys_" .. context .. "_" .. modded_key
                keymap_write_key(mod_id, key_id, context_id, reaper_key_script_id)
            else
                if defs.mod_decremented_keys[key] ~= nil then
                    mod_id = mod_id - 1
                end

                local modded_key, modded_key_name = format_modded_key(key, key_name, key_group, mod)
                gen_key(mod_id, modded_key, modded_key_name, key_id, context, context_id)
            end
        end
    end
end

local function codegen()
    io.open(keymap_path, "w"):close() -- truncate

    for context, context_id in pairs(defs.contexts) do
        for group_name, group in pairs(defs.key_group) do
            for key, key_id in pairs(group.keys) do
                local aliased_key = defs.aliases[key] or key
                gen_key(group.key_type_id, key, aliased_key, key_id, context, context_id)
                gen_modified_keys(key, key_id, aliased_key, group_name, context, context_id)
            end
        end
    end
end

codegen()
