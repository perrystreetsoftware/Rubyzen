# frozen_string_literal: true

require_relative '../spec_helper'
RSpec.describe 'Logger info calls include the details keyword arg' do
  let(:project) { Rubyzen::Project.new }

  context "given a class that calls LOGGER.info" do
    let(:logger_call_sites) do
      all_classes
        .all_methods
        .call_sites
        .filter do |cs|
          cs.receiver == 'LOGGER' && cs.method_name == 'info'
        end
    end

    it "includes the details keyword arg" do
      expect(logger_call_sites).to zen_true { |cs|
        cs.keyword_args.any? { |arg| arg == :details }
      }
    end
  end
end
