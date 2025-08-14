RSpec.describe 'No questions in models' do

  # This lint rule migrates this custom cop: https://github.com/perrystreetsoftware/Husband-Redis/blob/develop/linters/custom_cops/no_questions_in_models.rb
  context "given a class that resides in models" do
    let(:question_methods) { models.all_methods.filter { |m| m.name.end_with?('?')} }

    it "does not have questions in it" do
      expect(question_methods).to be_empty
    end
  end
end
