require 'spec_helper'

RSpec.describe Rubyzen::Collections::AssignmentsCollection do
  def assignments_of(body)
    file = parse_ruby(<<~RUBY)
      class Q
        def go
          #{body}
        end
      end
    RUBY
    file.classes.first.instance_methods.first.assignments
  end

  it '#with_name filters by variable name' do
    assignments = assignments_of("user = build\n        other = build")
    expect(assignments.with_name('user').map(&:name)).to eq(['user'])
  end

  it '#with_name returns the same collection type' do
    assignments = assignments_of("user = build\n        other = build")
    expect(assignments.with_name('user')).to be_a(described_class)
  end
end
