require 'rspec'
require 'rubyzen'
require 'pry'

RSpec.describe 'No if statements in controllers' do
  let(:project) { Rubyzen::Project.new }
  let(:controllers) { project.classes_with_name_ending_with("Controller") }
  let(:controller_classes) { project.classes_in_path('src/controllers') }

  let(:non_allowlisted_controllers) do
    controller_classes.excluding_classes_by_path(CONTROLLER_IF_STATEMENTS_ALLOWLIST)
  end

  context "given controller classes" do
    it "has no if statements in methods" do
      expect(non_allowlisted_controllers.all_methods.if_statements).to be_zen_empty
    end

    it "has no if statements in methods, using zen_true with a block" do
      expect(non_allowlisted_controllers.all_methods).to be_zen_true { |m|
        m.if_statements.count.zero?
      }
    end

    it "has no if statements in methods, using zen_false with a block" do
      expect(non_allowlisted_controllers.all_methods).to be_zen_false { |m|
        !m.if_statements.count.zero?
      }
    end

  end
end

CONTROLLER_IF_STATEMENTS_ALLOWLIST = [
].freeze
