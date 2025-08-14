# frozen_string_literal: true

RSpec.describe 'Presenters should not depend on repositories' do
  context 'given a presenter' do
    it 'does not directly access repositories' do
      expect(presenters.all_methods).to be_false { |method|
        method.constants.any? { |const| const.name.end_with?("Repository") }
      }
    end
  end
end
