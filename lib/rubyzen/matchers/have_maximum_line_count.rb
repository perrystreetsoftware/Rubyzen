require_relative 'matcher_helpers'

RSpec::Matchers.define :have_maximum_line_count do |max_lines, custom_message=nil|
  include Rubyzen::Matchers::MatcherHelpers

  match do |file_path|
    @custom_message = custom_message
    @max_lines = max_lines
    @file_path = file_path
    @offenders = []

    return false unless @file_path && File.exist?(@file_path)

    @actual_count = File.readlines(@file_path).size
    if @actual_count <= @max_lines
      true
    else
      @offenders << @file_path
      false
    end
  end

  failure_message do |file_path|
    message_for_failure("Expected #{@file_path} to have at most #{@max_lines} lines, but found #{@actual_count} lines.")
  end

  failure_message_when_negated do |file_path|
    message_for_failure("Expected #{@file_path} to have more than #{@max_lines} lines, but found #{@actual_count}.")
  end
end
