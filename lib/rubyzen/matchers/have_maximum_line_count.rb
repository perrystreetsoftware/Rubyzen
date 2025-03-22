require_relative 'matcher_helpers'

RSpec::Matchers.define :have_maximum_line_count do |max_lines, custom_message=nil|
  include Rubyzen::Matchers::MatcherHelpers

  match do |file|
    @custom_message = custom_message
    @max_lines = max_lines
    @offenders = []

    path = file.is_a?(String) ? file : file.path
    return false unless path && File.exist?(path)

    @actual_count = File.readlines(path).size
    if @actual_count <= @max_lines
      true
    else
      @offenders << path
      false
    end
  end

  failure_message do |_file|
    message_for_failure(
      "Expected #{@offenders.join(', ')} to have at most #{@max_lines} lines, but found #{@actual_count}."
    )
  end

  failure_message_when_negated do |_file|
    message_for_failure(
      "Expected #{@offenders.join(', ')} to have more than #{@max_lines} lines, but found #{@actual_count}."
    )
  end
end
