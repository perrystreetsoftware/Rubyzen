# frozen_string_literal: true

require_relative '../spec_helper'

RSpec.describe 'Do not stub core domain classes (Repos) in tests' do
  context 'given test files' do
    let(:test_source_files) { project.files.with_paths('src/tests/') }
    let(:stub_calls) { test_source_files.call_sites.with_name('allow') }

    it 'does not stub Repos constants' do
      expect(stub_calls).to zen_false { |cs|
        cs.arguments.first&.constant_name&.start_with?('Repos::')
      }
    end
  end
end
