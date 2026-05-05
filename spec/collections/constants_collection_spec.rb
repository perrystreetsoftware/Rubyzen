require 'spec_helper'

RSpec.describe Rubyzen::Collections::ConstantsCollection do
  let(:file) do
    parse_ruby(<<~RUBY)
      MAX = 100
      MIN = 0
      class Foo; end
    RUBY
  end

  let(:constants) { file.constants }

  describe 'CollectionFilterProvider' do
    it 'supports with_name' do
      assignments = constants.filter(&:assignment?)
      result = assignments.with_name('MAX')
      expect(result.size).to eq(1)
    end
  end
end
