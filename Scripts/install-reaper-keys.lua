-- @description reaper-keys: map keystroke combinations to actions like in vim
-- @version 2.0.0
-- @author gwatcha
-- @links
--   GitHub repository https://github.com/gwatcha/reaper-keys
-- @provides
--   ../definitions/*
--   ../internal/**/*

local defs = {
    contexts = {
        midi = 32060,
        main = 0
    },

    -- C -> ctrl, M -> alt, S -> shift
    mods = { C = 9, M = 17, S = 5, MS = 21, CS = 13, CM = 25, CMS = 29 },

    -- these key codes clash with others when modifiers are on, e.g.
    -- C-! will produce KEY 9 33 and will be parsed by reaper as C- Numpad Page Up
    -- reaper solves the problem by decrementing mod_id
    decrement_mod_id = {
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
    },

    aliases = {
        ['.'] = 'period',
        [':'] = 'colon',
        [','] = 'comma',
        ['<'] = 'lessthan',
        ['>'] = 'greaterthan',
        ['-'] = 'hyphen',
        ['_'] = 'underscore',
        [';'] = 'semicolon',
        ['?'] = 'questionmark',
        ['+'] = 'plus',
        ['!'] = 'exclamation',
        ["'"] = 'apostrophe',
        ['\\'] = 'backslash',
        ['|'] = 'pipe',
        ['*'] = 'asterisk',
        ['/'] = 'slash',
        ['#'] = 'numbersign',
        ['@'] = 'at',
        ['§'] = 'sectionsign',
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
    },

    -- keys that change to others when shifted (i.e. not like S-a -> A, but S-1 -> !)
    special_shift_keys = {
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
    },

    key_group = {
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
        letters = {
            key_type_id = 1,
            keys = {
                a = 65,
                b = 66,
                c = 67,
                d = 68,
                e = 69,
                f = 70,
                g = 71,
                h = 72,
                i = 73,
                j = 74,
                k = 75,
                l = 76,
                m = 77,
                n = 78,
                o = 79,
                p = 80,
                q = 81,
                r = 82,
                s = 83,
                t = 84,
                u = 85,
                v = 86,
                w = 87,
                x = 88,
                y = 89,
                z = 90,
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
        numbers = {
            key_type_id = 1,
            keys = {
                ['0'] = 48,
                ['1'] = 49,
                ['2'] = 50,
                ['3'] = 51,
                ['4'] = 52,
                ['5'] = 53,
                ['6'] = 54,
                ['7'] = 55,
                ['8'] = 56,
                ['9'] = 57
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
}

local function msg(...) reaper.ShowConsoleMsg(("%s\n"):format(string.format(...))) end

local root_dir_path = debug.getinfo(1, "S").source:match("@?(.*/)")
package.path = root_dir_path .. "../internal/install/defs.lua"

local codegen_dir = root_dir_path .. 'gen/'
local keymap_dir = reaper.GetResourcePath() .. '/KeyMaps/'
local keymap_path = keymap_dir .. 'reaper-keys.ReaperKeyMap'
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
    return ("SCR %d %d %s%s%s %s[reaper-keys] %s%s \"%s\"\n"):format(
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

    reaper.RecursiveCreateDirectory(keymap_dir, 0)
    io.open(keymap_path, "w"):close()

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
