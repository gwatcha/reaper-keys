local def = require "key_definitions"
local root_dir_path = debug.getinfo(1).source:match("@?(.*/)")
local key_script_dir = 'key_scripts'
local keymap_path = 'reaper-keys.ReaperKeyMap'

local function format_shifted_letter(key_mod, letter)
    --local modifier_keys_excluding_shift = key_mod[/(.*)S/, 1]
    if modifier_keys_excluding_shift == '' then
      local key = letter.upper()
      local key_name = "(" .. key_mod .. "-" .. letter .. ")"
      return {key, key_name}
    else
      local key = "<" .. modifier_keys_excluding_shift .. "-" .. letter.upper() .. ">"
      local key_name = "(" .. key_mod .. "-" .. letter .. ")"
      return {key, key_name}
    end
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

local function gen_key_script(key, context, path)
    local key_script_header =
        "local info = debug.getinfo(1,'S');" ..
        "local root_path = info.source:match[[([^@]*reaper.keys[^\\\\/]*[\\\\/])]];" ..
        "package.path = package.path .. ';' .. root_path .. '?.lua';" ..
        "local doInput = require('internal.reaper-keys')"

    if key == '\\' then
        key = '\\\\\\'
    elseif key == "'" then
        key = "\\\\'"
    end

    local input_line = "doInput({['key'] = '" .. key .. "', ['context'] = '" .. context .. "'})"

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
