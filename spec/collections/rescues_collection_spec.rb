require 'spec_helper'

RSpec.describe Rubyzen::Collections::RescuesCollection do
  let(:file) do
    parse_ruby(<<~RUBY)
      class Foo
        def bar
          begin
            x
          rescue ArgumentError
            handle_arg
          rescue TypeError
            handle_type
          end
        end
      end
    RUBY
  end

  let(:rescues) { file.classes.first.instance_methods.first.rescues }

  describe '#with_exception_type' do
    it 'filters by exception class' do
      result = rescues.with_exception_type('ArgumentError')
      expect(result.size).to eq(1)
    end

    it 'returns empty for non-matching type' do
      result = rescues.with_exception_type('RuntimeError')
      expect(result).to zen_empty
    end
  end
end
