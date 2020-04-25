#!/usr/bin/env ruby
# frozen_string_literal: true

require('./scripts/key_definitions')

class Generator
  def initialize(root_dir_name, keymap_path, key_script_dir, library_dir)
    @root_dir_name = root_dir_name
    @keymap_path = keymap_path
    @key_script_dir = key_script_dir
    @library_dir = library_dir
  end

  def gen_keymap()
    gen_key_scripts
    gen_library_scripts
  end

  def gen_key_script(key, context, path)
    key_script = ''"
local info = debug.getinfo(1,'S');
local root_path = info.source:match[[[^@]*reaper.keys/]]
package.path = package.path .. ';' .. root_path .. '?.lua'

local doInput = require('internal.reaper-keys')

doInput({['key'] = '#{key}', ['context'] = '#{context}'})
  "''
    open(path, 'w') { |file| file.puts key_script }
  end

  def format_keymap_scr_line(key, _context, context_id, script_id, key_script_path)
    desc = "[reaper-keys] [key_press] [#{key}]"
    if key[/"/]
      "SCR 4 #{context_id} \'#{script_id}\' \'#{desc}\' #{key_script_path}\n"
    else
      "SCR 4 #{context_id} \"#{script_id}\" \"#{desc}\" #{key_script_path}\n"
    end
  end

  def format_keymap_key_line(key_type_id, key_id, context_id, script_id)
    "KEY #{key_type_id} #{key_id} #{script_id} #{context_id}\n"
  end

  def gen_key(key_type_id, key, key_name, key_id, context, context_id)
    script_path = @key_script_dir + "#{context}_#{key_name}.lua"
    gen_key_script(key, context, script_path)

    reaper_key_script_id = "_reaper_keys_#{context}_#{key}"
    reaper_script_path = './' + @root_dir_name + script_path

    scr_line = format_keymap_scr_line(key, context, context_id, reaper_key_script_id, reaper_script_path)
    key_line = format_keymap_key_line(key_type_id, key_id, context_id, reaper_key_script_id)

    keymap_lines = scr_line + key_line
    open(@keymap_path, 'a') { |file| file.puts keymap_lines }
  end

  def gen_key_modifiers(key, key_id, key_name, key_table_name, context, context_id)
    KeyDefinitions::KEY_MODS.each do |key_mod, key_mod_id|
      modded_key = "<#{key_mod}-#{key}>"
      modded_key_name = "<#{key_mod}-#{key_name}>"

      key_has_surroundings = !key_name[/<(.*)>/, 1].nil?
      if key_has_surroundings
        key_name_without_surroundings = key_name[/<(.*)>/, 1]
        modded_key = "<#{key_mod}-#{key_name_without_surroundings}>"
        modded_key_name = modded_key
      end

      if %i[S MS CS CMS].detect { |x| x == key_mod }
        if key_table_name == :shifted || key_table_name == :normal
          next
        elsif key_table_name == :letters
          modifier_letters_excluding_shift = modded_key[/<(.*)S-#{key}>/, 1]
          modded_key = if modifier_letters_excluding_shift == ''
                         key.upcase
                       else
                         "<#{modifier_letters_excluding_shift}-#{key.upcase}>"
                       end
          modded_key_name = modded_key
        end
      end

      actual_key_mod_id = key_mod_id
      # these key codes clash with others when modifiers are on, reaper solves the problem by by decrementing the key_mod_id
      if KeyDefinitions::MOD_DECREMENTED_KEYS.detect { |x| x == key }
        actual_key_mod_id -= 1
      end

      gen_key(actual_key_mod_id, modded_key, modded_key_name, key_id, context, context_id)
    end
  end

  def gen_key_scripts
    KeyDefinitions::CONTEXTS.each do |context, context_id|
      KeyDefinitions::KEY_TABLE.each do |key_table_name, key_table|
        unmodded_key_type_id = key_table[:key_type_id]
        key_table[:keys].each do |key, key_id|
          key_name = key
          if KeyDefinitions::ALIASES[key]
            key_name = KeyDefinitions::ALIASES[key]
          end

          gen_key(unmodded_key_type_id, key, key_name, key_id, context, context_id)
          gen_key_modifiers(key, key_id, key_name, key_table_name, context, context_id)
        end
      end
    end
  end

  def gen_library_scripts
    Dir.foreach(@library_dir) do |file_name|
      next if (file_name == '.') || (file_name == '..')

      path = './' + @root_dir_name + @library_dir + file_name
      script_name = file_name[/(.*)\.lua/, 1]
      script_id = 'reaper-keys.' + script_name

      keymap_lines = ''
      desc = "[reaper-keys] [library] [#{script_name}]"

      KeyDefinitions::CONTEXTS.each do |_context, context_id|
        keymap_lines += "SCR 4 #{context_id} \"#{script_id}\" \"#{desc}\" #{path}\n"
      end

      open(@keymap_path, 'a') { |file| file.puts keymap_lines }
    end
  end


end

