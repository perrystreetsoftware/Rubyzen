# frozen_string_literal: true

require 'rspec'
require 'rubyzen'
require_relative '../spec_helper'

RSpec.describe 'Presenters should not depend on repositories' do
  context 'given a presenter' do
    it 'does not directly access repositories' do
      expect(presenters.all_methods).to be_false { |method|
        method.constants_referenced.any? { |const| const.end_with?("Repository") }
      }
    end
  end
end
