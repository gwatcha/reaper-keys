-- @description reaper-keys: map keystroke combinations to actions like in vim
-- @version 2.0.0-a
-- @author gwatcha
-- @links
--   GitHub repository https://github.com/gwatcha/reaper-keys
-- @provides
--   ../internal/**/*
--   ../vendor/**/*

local function charCodes(from, count)
    local out = {}
    for i = 0, count do out[i + 1] = from + i end
    return out
end

-- e.g. C-! will produce KEY 9 33 and will be parsed by reaper as C- Numpad Page Up
local clash = 65536
local key_groups = {
    letters = { mod_id = 1, keys = charCodes(65, 25) }, -- A-Z
    numbers = { mod_id = 1, keys = charCodes(48, 10) }, -- 0-9
    special = {
        mod_id = 1,
        keys = {
            8,     -- backspace
            9,     -- tab
            13,    -- return
            27,    -- esc
            32,    -- space
            112,   -- f1
            113,   -- f2
            114,   -- f3
            115,   -- f4
            116,   -- f5
            117,   -- f6
            118,   -- f7
            119,   -- f8
            120,   -- f9
            121,   -- f10
            122,   -- f11
            123,   -- f12,
            32801, -- page up
            32802, -- page down
            32803, -- end
            32804, -- home
            32805, -- left
            32806, -- up
            32807, -- right
            32808, -- down
            32813, -- insert
            32814, -- delete
        }
    },
    shifted = {
        mod_id = 0,
        keys = {
            33 + clash,  -- !
            34 + clash,  -- "
            35 + clash,  -- #
            36 + clash,  -- $
            37 + clash,  -- %
            38 + clash,  -- &
            40 + clash,  -- (
            41 + clash,  -- )
            42 + clash,  -- *
            43 + clash,  -- +
            58,          -- :
            60 + clash,  -- >
            62 + clash,  -- >
            63,          -- ?
            64,          -- @
            94,          -- ^
            95,          -- _
            123 + clash, -- {
            124 + clash, -- |
            125 + clash, -- }
            126,         -- ~
            126 + clash, -- ^
            126 + clash, -- *
        }
    },
    normal = {
        mod_id = 0,
        keys = {
            39 + clash, -- '
            44 + clash, -- ,
            45 + clash, -- -
            46 + clash, -- .
            47,         -- /
            59 + clash, -- ;
            61,         -- =
            91,         -- [
            92,         -- \
            93,         -- ]
            96 + clash, -- `
            167,        -- §
            177,        -- ±
        }
    }
}

local modifiers = { C = 9, M = 17, S = 5, MS = 21, CS = 13, CM = 25, CMS = 29 } -- C:ctrl, M:alt, S:shift
local mods_with_shift = { S = true, MS = true, CS = true, CMS = true }

local version = tonumber(reaper.GetAppVersion():match '[%d.]+')
if version < 6.71 then
    return reaper.MB("Reaper keys supports only Reaper 6.71+", "Unsupported version", 0)
end

local function concat_path(...) return table.concat({ ... }, package.config:sub(1, 1)) end

local keymap_dir = concat_path(reaper.GetResourcePath(), 'KeyMaps')
local keymap_path = concat_path(keymap_dir, 'reaper-keys.ReaperKeyMap')
reaper.RecursiveCreateDirectory(keymap_dir, 0)
local keymap = io.open(keymap_path, "w")
if not keymap then return reaper.MB("Failed to create " .. keymap_path, "Error", 0) end

function KEY(mod_id, key_id, command_id, section_id)
    return ("KEY %d %d %s %d\n"):format(mod_id, key_id, command_id, section_id)
end

local parent_dir = debug.getinfo(1, "S").source:match "@?(.*)[\\/].*[\\/]"
local command_path = concat_path(parent_dir, "internal", "rk.lua")
local sections = { midi = 32060, main = 0 }
for section_name, section_id in pairs(sections) do
    local command_id = "_reaper_keys__" .. section_name
    -- 260 focuses window on every key press so 516 is only option
    keymap:write(('SCR 516 %d %s "reaper-keys" "%s"\n'):format(section_id, command_id, command_path))

    for group_name, group in pairs(key_groups) do
        for _, key_id in pairs(group.keys) do
            local has_clash = (key_id >= clash) and 1 or 0
            key_id = key_id - has_clash * clash
            keymap:write(KEY(group.mod_id, key_id, command_id, section_id))

            for mod, mod_id in pairs(modifiers) do
                if group_name == "shifted" and mods_with_shift[mod] then goto iter_end end
                keymap:write(KEY(mod_id - has_clash, key_id, command_id, section_id))
                ::iter_end::
            end
        end
    end
end

local action_str = version >= 7. and "shortcuts/custom actions, import all sections" or ""
reaper.MB("Installation finished, now import reaper-keys.ReaperKeyMap:\n\t" ..
    "Actions list > Key Map > Import " .. action_str .. "\n" ..
    "WARNING: this will overwrite ALL your keybindings",
    "Installation finished", 0)
