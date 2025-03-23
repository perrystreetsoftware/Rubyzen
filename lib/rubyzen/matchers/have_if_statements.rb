require_relative 'matcher_helpers'

RSpec::Matchers.define :have_if_statements do |custom_message=nil|
  include Rubyzen::Matchers::MatcherHelpers

  match do |subject_collection|
    @custom_message = custom_message
    @offenders = []

    items = Array(subject_collection) # to handle one or multiple subjects

    items.each do |item|
      unless item.respond_to?(:if_statements)
        raise "Subject must implement IfStatementsProvider (missing #if_statements method)"
      end

      ifs = item.if_statements
      @offenders << offender_info(item, ifs) unless ifs.empty?
    end

    !@offenders.empty?
  end

  failure_message do |_|
    message_for_failure("Expected to find if-statements, but none were found.")
  end

  failure_message_when_negated do |_|
    message_for_failure("Expected no if-statements, but found them in: #{@offenders.join(', ')}")
  end

  def offender_info(item, if_statements)
    lines = if_statements.map(&:line).join(', ')
    name = (item.respond_to?(:name) ? item.name : 'UnknownDeclaration')
    "#{name} (if-statements at lines #{lines})"
  end
end
