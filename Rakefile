# frozen_string_literal: true

# Rakefile
require './scripts/generator'
require 'fileutils'

@root_dir_path = Dir.pwd[%r{[^/]*$}] + '/'
@key_script_dir = 'key_scripts/'
@keymap_path = 'reaper-keys.ReaperKeyMap'

task default: %i[clean build]

task :clean do
  FileUtils.rm_rf(@key_script_dir)
  Dir.mkdir(@key_script_dir)
  FileUtils.rm_f(@keymap_path)
end

task :build do
  generator = Generator.new(@root_dir_path, @keymap_path, @key_script_dir)
  generator.gen_interface
end
