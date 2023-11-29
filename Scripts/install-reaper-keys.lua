-- @description reaper-keys: map keystroke combinations to actions like in vim
-- @version 2.0.0
-- @author gwatcha
-- @links
--   GitHub repository https://github.com/gwatcha/reaper-keys
-- @provides
--   ../definitions/*
--   ../internal/**/*

local function msg(...) reaper.ShowConsoleMsg(("%s\n"):format(string.format(...))) end

local root_dir_path = debug.getinfo(1, "S").source:match("@?(.*/)")
package.path = root_dir_path .. "../internal/install/defs.lua"

local defs = require "defs"
local codegen_dir = root_dir_path .. 'gen/'
local keymap_path = reaper.GetResourcePath() .. '/KeyMaps/reaper-keys.ReaperKeyMap'
local mods_with_shift = { S = true, MS = true, CS = true, CMS = true }

local function formatShiftedLetter(mods, letter)
    local key = letter:upper()

    local mods_excluding_shift = mods:gsub("S", "")
    if mods_excluding_shift ~= '' then
        key = "<" .. mods_excluding_shift .. "-" .. key .. ">"
    end

    return key, "(" .. mods .. "-" .. letter .. ")"
end

local function formatModdedKey(key, key_name, key_group, mod)
    if mods_with_shift[mod] and key_group == "letters" then
        return formatShiftedLetter(mod, key)
    end

    if key:match("<(.*)>") then
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

local function keyScript(key, context)
    key = key:gsub("\\", "\\\\"):gsub("'", "\\'")
    return
        "package.path=debug.getinfo(1,'S').source:match[[([^@]*reaper.keys[^\\\\/]*[\\\\/])]]..'?.lua';" ..
        "require'internal.reaper-keys'{key='" .. key .. "',context='" .. context .. "'}"
end

-- https://mespotin.uber.space/Ultraschall/Reaper-Filetype-Descriptions.html#Reaper-kb.ini
local always_new_instance_for_script = 516

local function keymapKEYEntry(mod_id, key_id, script_id, context_id)
    return
        ("KEY %d %d %s %d\n"):format(mod_id, key_id, script_id, context_id)
end

local function keymapSCREntry(key, context_id, script_id, key_script_path)
    local quote = (key == '"') and "'" or '"'
    return ("SCR %d %d %s%s%s %s[reaper-keys] %s%s %s\n"):format(
        always_new_instance_for_script,
        context_id,
        quote, script_id, quote,
        quote, key, quote,
        key_script_path)
end

local function genKey(mod_id, key, key_name, key_id, context, context_id)
    local script_path = codegen_dir .. context .. "_" .. key_name .. ".lua"
    io.open(script_path, "w"):write(keyScript(key, context))

    local script_id = "_reaper_keys_" .. context .. "_" .. key_name -- script_id is case-insensitive

    io.open(keymap_path, "a"):write(
        keymapSCREntry(key, context_id, script_id, script_path) ..
        keymapKEYEntry(mod_id, key_id, script_id, context_id))
end

local function genKeysWithModifiers(key, key_id, key_name, key_group, context, context_id)
    for mod, mod_id in pairs(defs.mods) do
        local mod_has_shift = mods_with_shift[mod]

        if defs.decrement_mod_id[key] then
            mod_id = mod_id - 1
        end

        if key_group == "shifted" and mod_has_shift then
            goto iter_end
        end

        local special_shifted_key = defs.special_shift_keys[key]

        -- reuse scripts for special keys that are shifted (e.g. <[CM]S-1> -> <[CM]-!>)
        if mod_has_shift and special_shifted_key then
            local mod_without_shift = mod:match("([CM]+)S")
            local modded_key = special_shifted_key

            if mod_without_shift ~= nil then
                modded_key, _ = formatModdedKey(
                    special_shifted_key, special_shifted_key, 'shifted', mod_without_shift)
            end

            local reaper_key_script_id = "_reaper_keys_" .. context .. "_" .. modded_key
            io.open(keymap_path, "a"):write(
                keymapKEYEntry(mod_id, key_id, reaper_key_script_id, context_id))
        else
            local modded_key, modded_key_name = formatModdedKey(key, key_name, key_group, mod)
            genKey(mod_id, modded_key, modded_key_name, key_id, context, context_id)
        end

        ::iter_end::
    end
end

local function install()
    if reaper.RecursiveCreateDirectory(codegen_dir, 0) ~= 0 then
        return msg("Error creating %s", codegen_dir)
    end

    io.open(keymap_path, "w"):close() -- truncate keymap file just in case

    for context, context_id in pairs(defs.contexts) do
        for group_name, group in pairs(defs.key_group) do
            for key, key_id in pairs(group.keys) do
                local aliased_key = defs.aliases[key] or key -- avoid naming files like main_§
                genKey(group.key_type_id, key, aliased_key, key_id, context, context_id)
                genKeysWithModifiers(key, key_id, aliased_key, group_name, context, context_id)
            end
        end
    end

    local version = tonumber(reaper.GetAppVersion():match('[%d.]+'))
    local action_str = ""
    if version >= 7. then
        action_str = "shortcuts/custom actions, import all sections"
    end

    -- No way to auto-import https://forum.cockos.com/showthread.php?t=238798
    msg("Installation finished, now import reaper-keys.ReaperKeyMap:\n\t" ..
        "Actions list > Key Map > Import " .. action_str .. "\n" ..
        "WARNING: this will overwrite your current keymap, so back it up somewhere\n" ..
        "You can delete reaper-keys keymap file after importing")
end

install()
