local def = require "key_definitions"
--local root_dir_path = debug.getinfo(1).source:match("@?(.*/)")
local root_dir_path = "."
local key_script_dir = 'key_scripts/'
local keymap_path = 'reaper-keys.ReaperKeyMap'

local mods = { "S", "MS", "CS", "CMS" }

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

local function put_keymap_scr_line(key, context_id, script_id, key_script_path)
    local desc = "[reaper-keys] [key_press] [" .. key .. "]"
    local quote = (key == '"') and "'" or '"'
    io.open(keymap_path, "a"):write(
        "SCR 4 " .. context_id .. " " ..
        quote .. script_id .. quote .. " " ..
        quote .. desc .. quote .. " " ..
        key_script_path .. "\n"
    )
end

local function put_keymap_key_line(key_type_id, key_id, context_id, script_id)
    io.open(keymap_path, "a"):write(
        "KEY " .. key_type_id .. " " .. key_id .. " " .. script_id .. " " .. context_id .. "\n"
    )
end

local function format_modded_key(key, key_name, key_table_name, key_mod)
    local modded_key = "<" .. key_mod .. "-" .. key .. ">"
    local modded_key_name = "(" .. key_mod .. "-" .. key_name .. ")"

    local key_has_surroundings = string.match(key, "<(.*)>") ~= nil
    if key_has_surroundings then
        local key_without_surroundings = string.gsub(key, "<(.*)>", "")
        modded_key = "<" .. key_mod .. "-" .. key_without_surroundings .. ">"
        modded_key_name = "(" .. key_mod .. "-" .. key_without_surroundings .. ")"
    end

    if mods[key_mod] ~= nil and key_table_name == "letters" then
        modded_key, modded_key_name = format_shifted_letter(key_mod, key)
    end

    return modded_key, modded_key_name
end

local function gen_key_script(key, context, path)
    local key_script_header =
        "\nlocal info = debug.getinfo(1,'S');\n" ..
        "local root_path = info.source:match[[([^@]*reaper.keys[^\\\\/]*[\\\\/])]]\n" ..
        "package.path = package.path .. ';' .. root_path .. '?.lua'\n" ..
        "\nlocal doInput = require('internal.reaper-keys')\n"

    if key == '\\' then
        key = '\\\\\\'
    elseif key == "'" then
        key = "\\\\'"
    end

    local input_line = "\ndoInput({['key'] = '" .. key .. "', ['context'] = '" .. context .. "'})\n"

    io.open(path, "w"):write(key_script_header .. input_line)
end

local function gen_key(key_type_id, key, key_name, key_id, context, context_id)
    local script_path = key_script_dir .. context .. "_" .. key_name .. ".lua"
    gen_key_script(key, context, script_path)

    local reaper_key_script_id = "_reaper_keys_" .. context .. "_" .. key
    local reaper_script_path = './' .. root_dir_path .. script_path

    put_keymap_scr_line(key, context_id, reaper_key_script_id, reaper_script_path)
    put_keymap_key_line(key_type_id, key_id, context_id, reaper_key_script_id)
end

local function gen_modified_keys(key, key_id, key_name, key_table_name, context, context_id)
    for key_mod, key_mod_id in pairs(def.key_mods) do
        if not (key_table_name == "shifted" and mods[key_mod] ~= nil) then
            -- reuse the scripts for shifted keys that have shift characters (e.g. <S-1> -> !)
            -- but still put the keymap key lines in due to differences in how OS see '!' (as <S-1> or !)
            local shifted_key = def.shift_map[key]

            if shifted_key ~= nil and mods[key_mod] ~= nil then
                key_mod = string.gsub(key_mod, "([CM]+)S", "")
                local modded_key = shifted_key
                if key_mod then
                    modded_key, _ = format_modded_key(shifted_key, shifted_key, 'shifted', key_mod)
                end

                if def.mod_decremented_keys[key] then
                    key_mod_id = key_mod_id - 1
                end

                local reaper_key_script_id = "_reaper_keys_#{context}_#{modded_key}"
                put_keymap_key_line(key_mod_id, key_id, context_id, reaper_key_script_id)
            else
                if def.mod_decremented_keys[key] ~= nil then
                    key_mod_id = key_mod_id - 1
                end

                local modded_key, modded_key_name = format_modded_key(key, key_name, key_table_name, key_mod)
                gen_key(key_mod_id, modded_key, modded_key_name, key_id, context, context_id)
            end
        end
    end
end

local function gen_interface()
    for context, context_id in pairs(def.contexts) do
        for key_table_name, key_table in pairs(def.key_table) do
            local unmodded_key_type_id = key_table.key_type_id
            for key, key_id in pairs(key_table.keys) do
                local key_name = key

                if def.aliases[key] ~= nil then
                    key_name = def.aliases[key]
                end

                gen_key(unmodded_key_type_id, key, key_name, key_id, context, context_id)
                gen_modified_keys(key, key_id, key_name, key_table_name, context, context_id)
            end
        end
    end
end

gen_interface()
