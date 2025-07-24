require 'rspec'
require 'rubyzen'
require_relative '../spec_helper'

RSpec.describe 'Limit the maximum number of lines in a controller' do
  MAXIMUM_NUMBER_OF_LINES = 19

  it "Controllers should not exceed #{MAXIMUM_NUMBER_OF_LINES} lines" do
    expect(controllers.filter { |c| c.lines_of_code > MAXIMUM_NUMBER_OF_LINES })
      .to be_empty
  end
end
