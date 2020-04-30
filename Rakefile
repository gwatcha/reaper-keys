# frozen_string_literal: true

# Rakefile
require './scripts/generator'
require 'fileutils'

@root_dir_name = Dir.pwd[%r{[^/]*$}] + '/'
@key_script_dir = 'key_scripts/'
@keymap_path = 'reaper-keys.ReaperKeyMap'

task default: %i[clean:all gen:key_map]

namespace :clean do
  task all: %i[key_scripts key_map]
  task :key_scripts do
    FileUtils.rm_rf(@key_script_dir + '/*')
  end
  task :key_map do
    FileUtils.rm_f(@keymap_path)
  end
end

namespace :gen do
  generator = Generator.new(@root_dir_name, @keymap_path, @key_script_dir)

  task :key_map do
    generator.gen_keymap
  end
end
