# frozen_string_literal: true

# Rakefile
require './scripts/generator'
require './scripts/refractorer'
require 'fileutils'

@root_dir_path = Dir.pwd[%r{[^/]*$}] + '/'
@key_script_dir = 'key_scripts/'
@keymap_path = 'reaper-keys.ReaperKeyMap'
@definitions_dir = 'definitions/'

task default: %i[clean generate build]

task :clean do
  FileUtils.rm_rf(@key_script_dir)
  Dir.mkdir(@key_script_dir)
  FileUtils.rm_f(@keymap_path)
end

task :build do
  `rm -rf dist`
  `mkdir dist`
  `zip -r dist/reaper-keys.zip * -x dist img/* img`
end

task :generate do
  generator = Generator.new(@root_dir_path, @keymap_path, @key_script_dir)
  generator.gen_interface
end

namespace :refractor do
  refractorer = Refractorer.new(@definitions_dir)

  task :sort_actions do
    refractorer.sort_actions
  end

  task :delete_duplicate_actions do
    refractorer.delete_duplicate_actions
  end
end
