# frozen_string_literal: true

require_relative '../spec_helper'

RSpec.describe 'be_empty_with_exceptions' do
  let(:test_item_class) { Struct.new(:name, :class_name, :file_path, :line, keyword_init: true) }

  let(:root_path) { File.expand_path('../..', __dir__) }

  def build_item(name:, class_name:, file_path:, line: 1)
    test_item_class.new(name: name, class_name: class_name, file_path: file_path, line: line)
  end

  it 'groups baseline, allowlist, and live violations in the failure output' do
    baseline_item = build_item(
      name: 'index',
      class_name: 'Legacy::Controller',
      file_path: File.join(root_path, 'src/controllers/legacy_controller.rb'),
      line: 12
    )
    allowlisted_item = build_item(
      name: 'show',
      class_name: 'Allowed::Controller',
      file_path: File.join(root_path, 'src/controllers/allowed_controller.rb'),
      line: 18
    )
    violating_item = build_item(
      name: 'create',
      class_name: 'New::Controller',
      file_path: File.join(root_path, 'src/controllers/new_controller.rb'),
      line: 24
    )

    matcher = be_empty_with_exceptions(
      allowlist: ['Allowed::Controller'],
      baseline: ['Legacy::Controller']
    )

    expect(matcher.matches?([baseline_item, allowlisted_item, violating_item])).to be(false)
    expect(matcher.failure_message).to include('Expected to be empty, but found live violations.')
    expect(matcher.failure_message).to include('Violations:')
    expect(matcher.failure_message).to include('New::Controller')
    expect(matcher.failure_message).not_to include('Stale baseline entries:')
    expect(matcher.failure_message).not_to include('Stale allowlist entries:')
  end

  it 'matches baseline entries against file path suffixes' do
    item = build_item(
      name: 'call',
      class_name: 'Repo::UserRepo',
      file_path: File.join(root_path, 'src/repos/user_repo.rb'),
      line: 7
    )

    expect([item]).to be_empty_with_exceptions(baseline: ['src/repos/user_repo.rb'])
  end

  it 'fails when a baseline entry is no longer needed' do
    matcher = be_empty_with_exceptions(baseline: ['Legacy::Controller'])

    expect(matcher.matches?([])).to be(false)
    expect(matcher.failure_message).to include('Expected to be empty, but found stale baseline entries.')
    expect(matcher.failure_message).to include('Stale baseline entries:')
    expect(matcher.failure_message).to include('Legacy::Controller')
  end

  it 'uses a combined failure message when both live violations and stale baseline entries exist' do
    violating_item = build_item(
      name: 'create',
      class_name: 'New::Controller',
      file_path: File.join(root_path, 'src/controllers/new_controller.rb'),
      line: 24
    )

    matcher = be_empty_with_exceptions(baseline: ['Legacy::Controller'])

    expect(matcher.matches?([violating_item])).to be(false)
    expect(matcher.failure_message).to include('Expected to be empty, but found live violations and stale baseline entries.')
    expect(matcher.failure_message).to include('Violations:')
    expect(matcher.failure_message).to include('Stale baseline entries:')
  end

  it 'fails when an allowlist entry is no longer needed' do
    matcher = be_empty_with_exceptions(allowlist: ['Allowed::Controller'])

    expect(matcher.matches?([])).to be(false)
    expect(matcher.failure_message).to include('Expected to be empty, but found stale allowlist entries.')
    expect(matcher.failure_message).to include('Stale allowlist entries:')
    expect(matcher.failure_message).to include('Allowed::Controller')
  end

  it 'uses a combined failure message when live violations and stale allowlist entries exist' do
    violating_item = build_item(
      name: 'create',
      class_name: 'New::Controller',
      file_path: File.join(root_path, 'src/controllers/new_controller.rb'),
      line: 24
    )

    matcher = be_empty_with_exceptions(allowlist: ['Allowed::Controller'])

    expect(matcher.matches?([violating_item])).to be(false)
    expect(matcher.failure_message).to include('Expected to be empty, but found live violations and stale allowlist entries.')
    expect(matcher.failure_message).to include('Violations:')
    expect(matcher.failure_message).to include('Stale allowlist entries:')
  end
end