require 'rspec'
require 'rubyzen'
require_relative '../spec_helper'

RSpec.describe 'No top-level constants' do
  context 'given a file' do
    it 'does not define top level constants' do
      expect(files.constants).to zen_false { |const| const.assignment? && const.top_level? }
    end
  end
end
