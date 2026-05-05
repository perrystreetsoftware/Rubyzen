require 'spec_helper'

RSpec.describe Rubyzen::Collections::MacrosCollection do
  let(:file) do
    parse_ruby(<<~RUBY)
      class Foo
        validates_required :name
        belongs_to :user
      end
    RUBY
  end

  let(:macros) { file.classes.first.macros }

  describe 'CollectionFilterProvider' do
    it 'supports with_name' do
      result = macros.with_name('validates_required')
      expect(result.size).to eq(1)
    end

    it 'supports without_name' do
      result = macros.without_name('validates_required')
      expect(result.first.name).to eq('belongs_to')
    end
  end
end
