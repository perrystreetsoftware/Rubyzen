require 'rspec'
require 'rubyzen'
require_relative '../spec_helper'

RSpec.describe 'No complex logic in models' do
  MAXIMUM_NUMBER_OF_LINES = 5

  it "has no methods with more than #{MAXIMUM_NUMBER_OF_LINES} lines" do
    expect(models.all_methods.filter { |m| m.lines_of_code > MAXIMUM_NUMBER_OF_LINES }).to be_empty
  end
end
