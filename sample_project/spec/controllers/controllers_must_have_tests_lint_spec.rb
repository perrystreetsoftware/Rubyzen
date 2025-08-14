RSpec.describe 'Controllers must have tests' do
  let(:controller_test_files_set) { controller_test_files.map(&:path).to_set }

  it "Must have corresponding test file" do
    expect(controllers.filter do |c|
      !controller_test_files_set.any? { |f| f.end_with?(corresponding_spec_file(c.file_path)) }
    end).to be_empty
  end

  def corresponding_spec_file(source_file_path)
    relative_path = source_file_path.split('src/').last
    relative_path.sub(/\.rb$/, '_spec.rb')
  end
end
