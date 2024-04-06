-- @description reaper-keys: map keystroke combinations to actions like in vim
-- @version 2.0.0
-- @author gwatcha
-- @links
--   GitHub repository https://github.com/gwatcha/reaper-keys
-- @provides
--   ../definitions/*
--   ../internal/**/*
--   ../vendor/**/*
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

local modifiers = { C = 9, M = 17, S = 5, MS = 21, CS = 13, CM = 25, CMS = 29 } -- C:ctrl, M:alt, S:shift
local mods_with_shift = { S = true, MS = true, CS = true, CMS = true }

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

local version = tonumber(reaper.GetAppVersion():match('[%d.]+'))
if version < 6.71 then
    return reaper.ShowMessageBox(
        "Reaper keys supports only Reaper 6.71+", "Unsupported version", 0)
end

local keymap_dir = reaper.GetResourcePath() .. '/KeyMaps/'
local keymap_path = keymap_dir .. 'reaper-keys.ReaperKeyMap'
reaper.RecursiveCreateDirectory(keymap_dir, 0)
local keymap = io.open(keymap_path, "w")
if not keymap then
    return reaper.ShowMessageBox("Failed to create " .. keymap_path, "Error", 0)
end

function KEY(mod_id, key_id, script_id, context_id)
    return ("KEY %d %d %s %d\n"):format(mod_id, key_id, script_id, context_id)
end

local command_path = debug.getinfo(1, "S").source:match "@?(.*/)" .. "../internal/rk.lua"
local command_id_prefix = "_reaper_keys_"
local sections = { midi = 32060, main = 0 }
for section_name, section_id in pairs(sections) do
    local command_id = command_id_prefix .. "_" .. section_name
    keymap:write(('SCR 516 %d %s "reaper-keys" "%s"\n'):format(section_id, command_id, command_path))

    for group_name, group in pairs(key_groups) do
        for key, key_id in pairs(group.keys) do
            keymap:write(KEY(group.key_type_id, key_id, command_id, section_id))

            for mod, mod_id in pairs(modifiers) do
                local mod_has_shift = mods_with_shift[mod]

                if clashing_keys[key] then mod_id = mod_id - 1 end
                if group_name == "shifted" and mod_has_shift then goto iter_end end

                keymap:write(KEY(mod_id, key_id, command_id, section_id))
                ::iter_end::
            end
        end
    end
end

local action_str = version >= 7. and "shortcuts/custom actions, import all sections" or ""

-- Auto-import doesn't work on MacOS https://forums.cockos.com/showpost.php?p=2517650&postcount=15
reaper.ShowMessageBox("Installation finished, now import reaper-keys.ReaperKeyMap:\n\t" ..
    "Actions list > Key Map > Import " .. action_str .. "\n" ..
    "WARNING: this will overwrite your current keymap, so back it up somewhere",
    "Installation finished", 0)
