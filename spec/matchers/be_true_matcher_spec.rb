# frozen_string_literal: true

require_relative '../spec_helper'

RSpec.describe 'be_true' do
    let(:test_item_class) { Struct.new(:name, :class_name, :file_path, :line, keyword_init: true) }

  let(:root_path) { File.expand_path('../..', __dir__) }

  def build_item(class_name: 'Questions::Albums::Type', file_path: 'src/questions/albums/type.rb')
    test_item_class.new(
      name: 'private_album?',
      class_name: class_name,
      file_path: File.join(root_path, file_path),
      line: 10
    )
  end

  it 'fails when a baseline entry is stale' do
    matcher = be_true(baseline: ['Questions::Albums::Type']) { |_item| true }

    expect(matcher.matches?([build_item])).to be(false)
    expect(matcher.failure_message).to include('Expected to return true for all elements, but found stale baseline entries.')
    expect(matcher.failure_message).to include('Stale baseline entries:')
    expect(matcher.failure_message).to include('Questions::Albums::Type')
  end

  it 'treats baseline entries as expected failures when they still fail' do
    matcher = be_true(baseline: ['Questions::Albums::Type']) { |_item| false }

    expect(matcher.matches?([build_item])).to be(true)
  end

  it 'fails with expect syntax when baseline entry refers to a passing type' do
    items = [build_item]
    baseline = ['Questions::Albums::Type']
    matcher = be_true(baseline: baseline) { |_item| true }

    expect(matcher.matches?(items)).to be(false)
    expect(matcher.failure_message).to include('Stale baseline entries:')
    expect(matcher.failure_message).to include('Questions::Albums::Type')
  end

  it 'fails with expect syntax when baseline entry refers to a non-existent type' do
    items = [build_item]
    baseline = ['Questions::Albums::NonExistentTypeThatWasJustDeleted']
    matcher = be_true(baseline: baseline) { |_item| true }

    expect(matcher.matches?(items)).to be(false)
    expect(matcher.failure_message).to include('Stale baseline entries:')
    expect(matcher.failure_message).to include('Questions::Albums::NonExistentTypeThatWasJustDeleted')
  end

  it 'treats allowlisted entries as expected failures when they still fail' do
    matcher = be_true(allowlist: ['Questions::Albums::Type']) { |_item| false }

    expect(matcher.matches?([build_item])).to be(true)
  end

  it 'fails when an allowlist entry is stale' do
    matcher = be_true(allowlist: ['Questions::Albums::Type']) { |_item| true }

    expect(matcher.matches?([build_item])).to be(false)
    expect(matcher.failure_message).to include('Expected to return true for all elements, but found stale allowlist entries.')
    expect(matcher.failure_message).to include('Stale allowlist entries:')
    expect(matcher.failure_message).to include('Questions::Albums::Type')
  end

end
