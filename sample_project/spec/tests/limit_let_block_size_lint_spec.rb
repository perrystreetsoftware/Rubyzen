# frozen_string_literal: true

require_relative '../spec_helper'

RSpec.describe 'Limit let block size in test files' do
  let(:max_let_lines) { 5 }

  context 'given test files with let blocks' do
    let(:test_source_files) { project.files.with_paths('src/tests/') }

    let(:let_blocks) do
      test_source_files.blocks.with_method_name('let')
    end

    it 'does not have let blocks exceeding the max line limit' do
      expect(let_blocks).to be_false { |block| block.lines_of_code > max_let_lines }
    end
  end
end
