local def = require "key_definitions"
--local root_dir_path = debug.getinfo(1).source:match("@?(.*/)")
local root_dir_path = "."
local key_script_dir = 'key_scripts/'
local keymap_path = 'reaper-keys.ReaperKeyMap'

local mods_with_shift = { "S", "MS", "CS", "CMS" }

local function format_shifted_letter(key_mod, letter)
    local modifier_keys_excluding_shift = string.gsub(key_mod, "S", "")
    local key_name = "(" .. key_mod .. "-" .. letter .. ")"
    local key

    if modifier_keys_excluding_shift == '' then
        key = letter.upper()
    else
        key = "<" .. modifier_keys_excluding_shift .. "-" .. letter.upper() .. ">"
    end

    return key, key_name
end

local function format_modded_key(key, key_name, key_table_name, mod)
    local modded_key = "<" .. mod .. "-" .. key .. ">"
    local modded_key_name = "(" .. mod .. "-" .. key_name .. ")"

    local key_has_surroundings = string.match(key, "<(.*)>") ~= nil
    if key_has_surroundings then
        local key_without_surroundings = string.sub(key, 2, -2)
        modded_key = "<" .. mod .. "-" .. key_without_surroundings .. ">"
        modded_key_name = "(" .. mod .. "-" .. key_without_surroundings .. ")"
    end

    if mods_with_shift[mod] ~= nil and key_table_name == "letters" then
        modded_key, modded_key_name = format_shifted_letter(mod, key)
    end

    return modded_key, modded_key_name
end

local function key_script(key, context)
    if key == "\\" then key = "\\\\" end
    if key == "'" then key = "\'" end
    return
        "\nlocal info = debug.getinfo(1,'S');\n" ..
        "local root_path = info.source:match[[([^@]*reaper.keys[^\\\\/]*[\\\\/])]]\n" ..
        "package.path = package.path .. ';' .. root_path .. '?.lua'\n" ..
        "\nlocal doInput = require('internal.reaper-keys')\n\n" ..
        "doInput({['key'] = '" .. key .. "', ['context'] = '" .. context .. "'})\n"
end

local function keymap_write_key(key_type_id, key_id, context_id, script_id)
    io.open(keymap_path, "a"):write(
        "KEY " .. key_type_id .. " " .. key_id .. " " .. script_id .. " " .. context_id .. "\n"
    )
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

local function gen_modified_keys(key, key_id, key_name, key_table_name, context, context_id)
    for mod, mod_id in pairs(def.mods) do
        local has_shift = mods_with_shift[mod] ~= nil

        if not (key_table_name == "shifted" and has_shift) then
            -- reuse the scripts for shifted keys that have shift characters (e.g. <S-1> -> !)
            -- but still put the keymap key lines in due to differences in how OS sees '!' (as <S-1> or !)
            local shifted_key = def.shift_map[key]

            if shifted_key ~= nil and has_shift then
                mod = string.gsub(mod, "([CM]+)S", "")
                local modded_key = shifted_key
                if mod then
                    modded_key, _ = format_modded_key(shifted_key, shifted_key, 'shifted', mod)
                end

                if def.mod_decremented_keys[key] ~= nil then
                    mod_id = mod_id - 1
                end

                local reaper_key_script_id = "_reaper_keys_" .. context .. "_" .. modded_key
                keymap_write_key(mod_id, key_id, context_id, reaper_key_script_id)
            else
                if def.mod_decremented_keys[key] ~= nil then
                    mod_id = mod_id - 1
                end

                local modded_key, modded_key_name = format_modded_key(key, key_name, key_table_name, mod)

                gen_key(mod_id, modded_key, modded_key_name, key_id, context, context_id)
            end
        end
    end
end

local function codegen()
    for context, context_id in pairs(def.contexts) do
        for group_name, group in pairs(def.key_group) do
            for key, key_id in pairs(group.keys) do
                local aliased_key = def.aliases[key] or key
                gen_key(group.key_type_id, key, aliased_key, key_id, context, context_id)
                gen_modified_keys(key, key_id, aliased_key, group_name, context, context_id)
            end
        end
    end
end

codegen()
