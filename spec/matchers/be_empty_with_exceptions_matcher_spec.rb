require 'spec_helper'

RSpec.describe 'be_empty_with_exceptions matcher' do
  let(:file) do
    parse_ruby(<<~RUBY, file_path: '/app/controllers/foo_controller.rb')
      class FooController; end
      class BarController; end
    RUBY
  end

  let(:classes) { Rubyzen::Collections::ClassesCollection.new(file.classes) }

  describe 'with allowlist' do
    it 'passes when all items are allowlisted' do
      expect(classes).to be_empty_with_exceptions(
        allowlist: ['FooController', 'BarController']
      )
    end

    it 'fails when there are non-allowlisted items' do
      expect {
        expect(classes).to be_empty_with_exceptions(
          allowlist: ['FooController']
        )
      }.to raise_error(RSpec::Expectations::ExpectationNotMetError, /violations/i)
    end

    it 'fails on stale allowlist entries' do
      expect {
        expect(classes).to be_empty_with_exceptions(
          allowlist: ['FooController', 'BarController', 'NonExistent']
        )
      }.to raise_error(RSpec::Expectations::ExpectationNotMetError, /stale/i)
    end
  end

  describe 'with baseline' do
    it 'passes when all items are in baseline' do
      expect(classes).to be_empty_with_exceptions(
        baseline: ['FooController', 'BarController']
      )
    end

    it 'fails on stale baseline entries' do
      expect {
        expect(classes).to be_empty_with_exceptions(
          baseline: ['FooController', 'BarController', 'OldClass']
        )
      }.to raise_error(RSpec::Expectations::ExpectationNotMetError, /stale/i)
    end
  end

  describe 'deprecation' do
    it 'emits a deprecation warning' do
      expect {
        expect(classes).to be_empty_with_exceptions(
          allowlist: ['FooController', 'BarController']
        )
      }.to output(/DEPRECATION/).to_stderr
    end
  end

  describe 'with empty collection' do
    let(:empty) { Rubyzen::Collections::ClassesCollection.new }

    it 'passes with no exceptions' do
      expect(empty).to be_empty_with_exceptions
    end

    it 'fails on stale baseline with empty collection' do
      expect {
        expect(empty).to be_empty_with_exceptions(baseline: ['Ghost'])
      }.to raise_error(RSpec::Expectations::ExpectationNotMetError, /stale/i)
    end
  end
end
