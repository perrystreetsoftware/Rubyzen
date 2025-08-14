RSpec.describe 'Limit the maximum number of lines in a controller' do
  let(:maximum_number_of_lines) { 19 }

  it 'Controllers should not exceed max lines' do
    expect(controllers.filter { |c| c.lines_of_code > maximum_number_of_lines })
      .to be_empty
  end
end
