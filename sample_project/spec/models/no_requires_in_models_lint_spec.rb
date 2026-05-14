require 'rspec'
require 'rubyzen'
require_relative '../spec_helper'

RSpec.describe 'No requires in model files' do
  context 'given a domain model' do
    it 'does not contain require statements' do
      expect(models_files.requires).to zen_empty
    end
  end
end
