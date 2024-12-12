require 'rspec'
require 'rubyzen'

RSpec.describe 'Logger lint rules' do
  let(:project) { Rubyzen::Project.new }

  context "given a class that calls LOGGER.info" do
    let(:classes) { project.classes }

    it "includes the details param" do
      expect(classes)
        .to(require_keyword_argument_in_calls('LOGGER', 'info', :details, "LOGGER.info requires a details keyword argument, otherwise it will fail in the dev environment"))
    end
  end
end

# This lint rule solves this comment: https://github.com/perrystreetsoftware/Husband-Redis/pull/4679#discussion_r1857501620
