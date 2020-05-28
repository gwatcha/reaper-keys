# frozen_string_literal: true

require('./scripts/key_definitions')

class Generator
  def initialize(root_dir_path, keymap_path, key_script_dir)
    @root_dir_path = root_dir_path
    @keymap_path = keymap_path
    @key_script_dir = key_script_dir
  end

  def format_shifted_letter(key_mod, letter)
    modifier_keys_excluding_shift = key_mod[/(.*)S/, 1]
    key = ''
    key_name = "(#{key_mod}-#{letter})"
    if modifier_keys_excluding_shift == ''
      key = letter.upcase
    else
      key = "<#{modifier_keys_excluding_shift}-#{letter.upcase}>"
      key_name = "(#{key_mod}-#{letter})"
    end
    [key, key_name]
  end

  def format_modded_key(key, key_name, key_table_name, key_mod)
    modded_key = "<#{key_mod}-#{key}>"
    modded_key_name = "(#{key_mod}-#{key_name})"

    key_has_surroundings = !key[/<(.*)>/, 1].nil?
    if key_has_surroundings
      key_without_surroundings = key[/<(.*)>/, 1]
      modded_key = "<#{key_mod}-#{key_without_surroundings}>"
      modded_key_name = "(#{key_mod}-#{key_without_surroundings})"
    end

    if %i[S MS CS CMS].include?(key_mod) && (key_table_name == :letters)
      modded_key, modded_key_name = format_shifted_letter(key_mod, key)
    end

    [modded_key, modded_key_name]
  end

  def gen_modified_keys(key, key_id, key_name, key_table_name, context, context_id)
    KeyDefinitions::KEY_MODS.each do |key_mod, key_mod_id|
      next if %i[shifted].include?(key_table_name) &&
              %i[S MS CS CMS].include?(key_mod)

      # reuse the scripts for shifted keys that have shift characters (e.g. <S-1> -> !)
      # but still put the keymap key lines in due to differences in how OS see '!' (as <S-1> or !)
      if KeyDefinitions::SHIFT_MAP[key] && %i[S MS CS CMS].include?(key_mod)
        shifted_key = KeyDefinitions::SHIFT_MAP[key]
        key_mod = key_mod[/([CM]+)S/, 1]
        modded_key = shifted_key
        if key_mod
          modded_key, = format_modded_key(shifted_key, shifted_key, 'shifted', key_mod)
        end

        if KeyDefinitions::MOD_DECREMENTED_KEYS.detect { |x| x == key }
          key_mod_id -= 1
        end

        reaper_key_script_id = "_reaper_keys_#{context}_#{modded_key}"
        put_keymap_key_line(key_mod_id, key_id, context_id, reaper_key_script_id)
        next
      end

      if KeyDefinitions::MOD_DECREMENTED_KEYS.detect { |x| x == key }
        key_mod_id -= 1
      end

      modded_key, modded_key_name = format_modded_key(key, key_name, key_table_name, key_mod)

      gen_key(key_mod_id, modded_key, modded_key_name, key_id, context, context_id)
    end
  end

  def put_keymap_scr_line(key, context_id, script_id, key_script_path)
    desc = "[reaper-keys] [key_press] [#{key}]"
    scr_line = nil
    if key[/"/]
      scr_line = "SCR 4 #{context_id} \'#{script_id}\' \'#{desc}\' #{key_script_path}\n"
    else
      scr_line = "SCR 4 #{context_id} \"#{script_id}\" \"#{desc}\" #{key_script_path}\n"
    end
    open(@keymap_path, 'a') { |file| file.puts scr_line }
  end

  def put_keymap_key_line(key_type_id, key_id, context_id, script_id)
    key_line = "KEY #{key_type_id} #{key_id} #{script_id} #{context_id}\n"
    open(@keymap_path, 'a') { |file| file.puts key_line }
  end

  def gen_key_script(key, context, path)
    key_script_header = ''"
local info = debug.getinfo(1,'S');
local root_path = info.source:match[[([^@]*reaper.keys[^\\\\/]*[\\\\/])]]
package.path = package.path .. ';' .. root_path .. '?.lua'

local doInput = require('internal.reaper-keys')

"''
    safe_key = key
    safe_key = key.gsub('\\', '\\\\\\') if key['\\']
    safe_key = key.gsub("'", "\\\\'") if key["'"]

    input_line = "doInput({['key'] = '#{safe_key}', ['context'] = '#{context}'})"

    key_script = key_script_header + input_line
    open(path, 'w') { |file| file.puts key_script }
  end

  def gen_key(key_type_id, key, key_name, key_id, context, context_id)
    script_path = @key_script_dir + "#{context}_#{key_name}.lua"
    gen_key_script(key, context, script_path)

    reaper_key_script_id = "_reaper_keys_#{context}_#{key}"
    reaper_script_path = './' + @root_dir_path + script_path

    put_keymap_scr_line(key, context_id, reaper_key_script_id, reaper_script_path)
    put_keymap_key_line(key_type_id, key_id, context_id, reaper_key_script_id)
  end

  def gen_interface
    KeyDefinitions::CONTEXTS.each do |context, context_id|
      KeyDefinitions::KEY_TABLE.each do |key_table_name, key_table|
        unmodded_key_type_id = key_table[:key_type_id]
        key_table[:keys].each do |key, key_id|
          key_name = key

          if KeyDefinitions::ALIASES[key]
            key_name = KeyDefinitions::ALIASES[key]
          end

          gen_key(unmodded_key_type_id, key, key_name, key_id, context, context_id)
          gen_modified_keys(key, key_id, key_name, key_table_name, context, context_id)
        end
      end
    end
  end
end
