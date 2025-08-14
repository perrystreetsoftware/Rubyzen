RSpec.describe 'Repositories lint rules' do
  context "given a repository" do

    it "is within a Repos module" do
      expect(repos).to be_true { |repo|
        repo.top_level_module == 'Repos'
    }
    end
  end
end
