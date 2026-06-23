# frozen_string_literal: true

require_relative '../spec_helper'

RSpec.describe 'Admin API calls must use with_admin_context' do
  context 'given test files' do
    let(:test_source_files) { project.files.with_paths('src/tests/') }

    let(:admin_calls) do
      test_source_files.call_sites
        .with_name('get')
        .filter { |cs| cs.strings.any? { |path| path.start_with?('/admin/') } }
    end

    it 'wraps admin calls in a with_admin_context block' do
      expect(admin_calls).to zen_true { |cs|
        cs.enclosing_blocks.with_name('with_admin_context').any?
      }
    end
  end
end
