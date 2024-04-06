-- @description reaper-keys: map keystroke combinations to actions like in vim
-- @version 2.0.0
-- @author gwatcha
-- @links
--   GitHub repository https://github.com/gwatcha/reaper-keys
-- @provides
--   ../definitions/*
--   ../internal/**/*
--   ../vendor/**/*

local contexts = { midi = 32060, main = 0 }
local modifiers = { C = 9, M = 17, S = 5, MS = 21, CS = 13, CM = 25, CMS = 29 } -- C:ctrl, M:alt, S:shift
local mods_with_shift = { S = true, MS = true, CS = true, CMS = true }
local aliases = {
    ['.'] = 'period',
    [':'] = 'colon',
    [','] = 'comma',
    ['<'] = 'less',
    ['>'] = 'greater',
    ['-'] = 'hyphen',
    ['_'] = 'underscore',
    [';'] = 'semicolon',
    ['?'] = 'question',
    ['+'] = 'plus',
    ['!'] = 'exclamation',
    ["'"] = 'apostrophe',
    ['\\'] = 'backslash',
    ['|'] = 'pipe',
    ['*'] = 'asterisk',
    ['/'] = 'slash',
    ['#'] = 'hashtag',
    ['@'] = 'at',
    ['§'] = 'section',
    ['~'] = 'tilde',
    ['±'] = 'plusminus',
    [']'] = 'closebracket',
    ['['] = 'openbracket',
    ['('] = 'openparen',
    [')'] = 'closeparen',
    ['$'] = 'dollar',
    ['%'] = 'percent',
    ['&'] = 'ampersand',
    ['"'] = 'quotation',
    ['}'] = 'closewing',
    ['{'] = 'openwing',
    ['='] = 'equals',
    ['`'] = 'backtick',
    ['<left>'] = 'left',
    ['<up>'] = 'up',
    ['<right>'] = 'right',
    ['<down>'] = 'down',
    ['<F1>'] = 'F1',
    ['<F2>'] = 'F2',
    ['<F3>'] = 'F3',
    ['<F4>'] = 'F4',
    ['<F5>'] = 'F5',
    ['<F6>'] = 'F6',
    ['<F7>'] = 'F7',
    ['<F8>'] = 'F8',
    ['<F9>'] = 'F9',
    ['<F10>'] = 'F10',
    ['<backspace>'] = 'backspace',
    ['<SPC>'] = 'SPC',
    ['<TAB>'] = 'TAB',
    ['<ESC>'] = 'ESC',
    ['<return>'] = 'return'
}
-- C-! will produce KEY 9 33 and will be parsed by reaper as C- Numpad Page Up
local clashing_keys = {
    ['`'] = true,
    ["'"] = true,
    ['%'] = true,
    ['&'] = true,
    ['('] = true,
    [')'] = true,
    ['{'] = true,
    ['}'] = true,
    ['|'] = true,
    ['.'] = true,
    ['!'] = true,
    ['#'] = true,
    ['$'] = true,
    ['^'] = true,
    ['*'] = true,
    [','] = true,
    ['-'] = true,
    ['"'] = true,
    ['>'] = true,
    ['<'] = true,
    ['+'] = true,
    [';'] = true
}
local special_shift_keys = {
    ['`'] = '~',
    ['/'] = '?',
    ['='] = '+',
    ['['] = '{',
    [']'] = '}',
    [';'] = ':',
    ['-'] = '_',
    ['.'] = '>',
    [','] = '<',
    ['\\'] = '|',
    ["'"] = '"',
    ['0'] = ')',
    ['9'] = '(',
    ['8'] = '*',
    ['7'] = '&',
    ['6'] = '^',
    ['5'] = '%',
    ['4'] = '$',
    ['3'] = '#',
    ['2'] = '@',
    ['1'] = '!'
}

local function charCodes(from_num, from_char, to_char) -- reaper uses non-Ascci codes
    local from_char_num, to_char_num, out = string.byte(from_char), string.byte(to_char), {}
    for i = 0, to_char_num - from_char_num do
        out[string.char(from_char_num + i)] = from_num + i
    end
    return out
end

local key_groups = {
    letters = { key_type_id = 1, keys = charCodes(65, 'a', 'z') },
    numbers = { key_type_id = 1, keys = charCodes(48, '0', '9') },
    special = {
        key_type_id = 1,
        keys = {
            ['<left>'] = 37,
            ['<up>'] = 38,
            ['<right>'] = 39,
            ['<down>'] = 40,
            ['<F1>'] = 112,
            ['<F2>'] = 113,
            ['<F3>'] = 114,
            ['<F4>'] = 115,
            ['<F5>'] = 116,
            ['<F6>'] = 117,
            ['<F7>'] = 118,
            ['<F8>'] = 119,
            ['<F9>'] = 120,
            ['<F10>'] = 121,
            ['<backspace>'] = 8,
            ['<SPC>'] = 32,
            ['<TAB>'] = 9,
            ['<ESC>'] = 27,
            ['<return>'] = 13,
        }
    },
    shifted = {
        key_type_id = 0,
        keys = {
            ['!'] = 33,
            ['@'] = 64,
            ['#'] = 35,
            ['$'] = 36,
            ['%'] = 37,
            ['^'] = 126,
            ['&'] = 38,
            ['*'] = 126,
            ['('] = 40,
            [')'] = 41,
            ['"'] = 34,
            ['|'] = 124,
            ['<'] = 60,
            ['>'] = 62,
            ['_'] = 95,
            [':'] = 58,
            ['}'] = 125,
            ['{'] = 123,
            ['+'] = 43,
            ['?'] = 63,
            ['~'] = 126,
        }
    },
    normal = {
        key_type_id = 0,
        keys = {
            ["'"] = 39,
            ['.'] = 46,
            [','] = 44,
            ['-'] = 45,
            [';'] = 59,
            ['\\'] = 92,
            ['/'] = 47,
            ['§'] = 167,
            ['±'] = 177,
            [']'] = 93,
            ['['] = 91,
            ['='] = 61,
            ['`'] = 96,
        }
    }
}

local function msg(...) reaper.ShowConsoleMsg(("%s\n"):format(string.format(...))) end

local root = debug.getinfo(1, "S").source:match "@?(.*/)"
local codegen_dir = root .. 'gen/'
local keymap_dir = reaper.GetResourcePath() .. '/KeyMaps/'
local keymap_path = keymap_dir .. 'reaper-keys.ReaperKeyMap'

local function formatShiftedLetter(mods, letter)
    local key = letter:upper()

    local mods_without_shift = mods:gsub("S", "")
    if mods_without_shift ~= '' then
        key = "<" .. mods_without_shift .. "-" .. key .. ">"
    end

    return key, "(" .. mods .. "-" .. letter .. ")"
end

local function formatModdedKey(key, key_name, key_group, mod)
    if mods_with_shift[mod] and key_group == "letters" then
        return formatShiftedLetter(mod, key)
    end

    if key:match "<(.*)>" then
        local key_without_cases = key:sub(2, -2)
        return
            ("<%s-%s>"):format(mod, key_without_cases),
            ("(%s-%s)"):format(mod, key_without_cases)
    else
        return
            ("<%s-%s>"):format(mod, key),
            ("(%s-%s)"):format(mod, key_name)
    end
end

local function script(key, context)
    key = key:gsub("\\", "\\\\"):gsub("'", "\\'")
    return
        "package.path=debug.getinfo(1,'S').source:match[[([^@]*reaper.keys[^\\\\/]*[\\\\/])]]..'?.lua';" ..
        "require'rk'{key='" .. key .. "',context='" .. context .. "'}"
end

local function KEY(mod_id, key_id, script_id, context_id)
    return ("KEY %d %d %s %d\n"):format(mod_id, key_id, script_id, context_id)
end

local function SCR(key, context_id, script_id, key_script_path)
    -- https://mespotin.uber.space/Ultraschall/Reaper-Filetype-Descriptions.html#Reaper-kb.ini
    local always_new_instance_for_script = 516

    local quote = (key == '"') and "'" or '"'
    return ("SCR %d %d %s%s%s %s[reaper-keys] %s%s \"%s\"\n"):format(
        always_new_instance_for_script,
        context_id,
        quote, script_id, quote,
        quote, key, quote,
        key_script_path)
end

local function genKey(mod_id, key, key_name, key_id, context, context_id)
    local script_path = codegen_dir .. context .. "_" .. key_name .. ".lua"
    io.open(script_path, "w"):write(script(key, context))

    local script_id = "_reaper_keys_" .. context .. "_" .. key_name -- script_id is case-insensitive

    io.open(keymap_path, "a"):write(
        SCR(key, context_id, script_id, script_path) ..
        KEY(mod_id, key_id, script_id, context_id))
end

local function genKeysWithModifiers(key, key_id, key_name, key_group, context, context_id)
    for mod, mod_id in pairs(modifiers) do
        local mod_has_shift = mods_with_shift[mod]

        if clashing_keys[key] then
            mod_id = mod_id - 1
        end

        if key_group == "shifted" and mod_has_shift then
            goto iter_end
        end

        local special_shifted_key = special_shift_keys[key]

        -- reuse scripts for special keys that are shifted (e.g. <[CM]S-1> -> <[CM]-!>)
        if mod_has_shift and special_shifted_key then
            local mod_without_shift = mod:match "([CM]+)S"
            local modded_key = special_shifted_key

            if mod_without_shift ~= nil then
                modded_key, _ = formatModdedKey(
                    special_shifted_key, special_shifted_key, 'shifted', mod_without_shift)
            end

            local reaper_key_script_id = "_reaper_keys_" .. context .. "_" .. modded_key
            io.open(keymap_path, "a"):write(KEY(mod_id, key_id, reaper_key_script_id, context_id))
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

    reaper.RecursiveCreateDirectory(keymap_dir, 0)
    io.open(keymap_path, "w"):close()

    for context, context_id in pairs(contexts) do
        for group_name, group in pairs(key_groups) do
            for key, key_id in pairs(group.keys) do
                local aliased_key = aliases[key] or key
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
