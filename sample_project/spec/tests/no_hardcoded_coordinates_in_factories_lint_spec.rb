# frozen_string_literal: true

require_relative '../spec_helper'

RSpec.describe 'Use location traits instead of hardcoded coordinates in profile factories' do
  context 'given test files' do
    let(:test_source_files) { project.files.with_paths('src/tests/') }

    let(:profile_factory_calls) do
      test_source_files.call_sites
        .with_name('create')
        .with_symbol(:profile)
    end

    it 'does not hardcode latitude and longitude in profile factory calls' do
      expect(profile_factory_calls).to zen_false { |cs|
        cs.keyword_arg_value_pairs[:latitude].is_a?(Numeric) ||
          cs.keyword_arg_value_pairs[:longitude].is_a?(Numeric)
      }
    end
  end
end
