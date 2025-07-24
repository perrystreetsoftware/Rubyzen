require 'rspec'
require 'rubyzen'
require_relative '../spec_helper'

RSpec.describe 'No complex logic in models' do
  let(:maximum_number_of_lines) { 19 }

  it 'has no methods with more than max lines' do
    expect(models.all_methods.filter { |m| m.lines_of_code > maximum_number_of_lines }).to be_empty
  end
end
