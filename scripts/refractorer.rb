# frozen_string_literal: true

class Refractorer
  def initialize(definitions_dir)
    @definitions_dir = definitions_dir
    @actions = @definitions_dir + 'actions.lua'
    @bindings = Hash[
      'global' => @definitions_dir + 'global.lua',
      'midi' => @definitions_dir + 'midi.lua',
      'main' => @definitions_dir + 'main.lua',
    ]
  end

  def overwrite_actions(action_definitions)
    header, footer = '', ''
    definition_started = false
    File.foreach(@actions) do |line|
      if line.match?(/.*=.*,\n/)
        definition_started = true
      elsif definition_started
        footer += line
      else
        header += line
      end
    end

    new_actions = header + action_definitions + footer
    File.open(@actions, 'w').puts new_actions
  end

  def get_action_definitions
    action_definitions = ''
    File.foreach(@actions) do |line|
      if line.match?(/.*=.*,\n/)
        action_definitions += line
      end
    end
    action_definitions
  end

  def sort_actions
    File.open('tmp.txt', 'w').puts get_action_definitions
    sorted_action_definitions = `sort tmp.txt`
    `rm tmp.txt`
    overwrite_actions(sorted_action_definitions)
  end

  def delete_duplicate_actions
    unique_action_definitions = get_action_definitions.lines.uniq.join()
    overwrite_actions(unique_action_definitions)
  end

  def get_all_bound_actions
    all_bindings = `cat #{@bindings['midi']} #{@bindings['main']} #{@bindings['global']}`

    bound_actions = ''
    all_bindings.each_line do |line|
      if line.match?(/\[.*\] = ".*"/)
        bound_actions += line[/= "(.*)"/, 1] + '\n'
      end
    end

    return bound_actions
  end
end
