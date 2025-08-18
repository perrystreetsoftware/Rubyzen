require 'rspec'
require 'rubyzen'
require_relative '../spec_helper'

RSpec.describe 'Module file path consistency' do
  context 'given a module' do
    it 'resides in a file that includes its name in the path' do
      expect(all_modules).to be_true { |mod| mod.file_path.downcase.include?(mod.name_without_modules.downcase) }
    end
  end
end
