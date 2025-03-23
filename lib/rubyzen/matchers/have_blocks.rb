require_relative 'matcher_helpers'

RSpec::Matchers.define :have_blocks do |custom_message=nil|
  include Rubyzen::Matchers::MatcherHelpers

  match do |subject_collection|
    @custom_message = custom_message
    @offenders = []

    items = Array(subject_collection)

    items.each do |item|
      unless item.respond_to?(:blocks)
        raise "Subject must implement BlocksProvider (missing #blocks method)"
      end

      blks = item.blocks
      @offenders << offender_info(item, blks) unless blks.empty?
    end

    !@offenders.empty?
  end

  failure_message do |_|
    message_for_failure("Expected to find blocks, but none were found.")
  end

  failure_message_when_negated do |_|
    message_for_failure("Expected no blocks, but found them in: #{@offenders.join(', ')}")
  end

  def offender_info(item, blocks)
    lines = blocks.map(&:line).join(', ')
    name  = (item.respond_to?(:name) ? item.name : 'UnknownDeclaration')
    "#{name} (blocks at lines #{lines})"
  end
end
