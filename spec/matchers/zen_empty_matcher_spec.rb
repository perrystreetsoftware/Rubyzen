require 'spec_helper'

RSpec.describe 'zen_empty matcher' do
  let(:empty_collection) { Rubyzen::Collections::ClassesCollection.new }
  let(:non_empty_collection) do
    file = parse_ruby('class Foo; end')
    Rubyzen::Collections::ClassesCollection.new(file.classes)
  end

  it 'passes when collection is empty' do
    expect(empty_collection).to zen_empty
  end

  it 'fails when collection is not empty' do
    expect {
      expect(non_empty_collection).to zen_empty
    }.to raise_error(RSpec::Expectations::ExpectationNotMetError, /Expected to be empty/)
  end

  it 'supports custom failure message' do
    expect {
      expect(non_empty_collection).to zen_empty("Controllers should not have violations")
    }.to raise_error(RSpec::Expectations::ExpectationNotMetError, /Controllers should not have violations/)
  end

  it 'supports negation' do
    expect(non_empty_collection).not_to zen_empty
  end

  describe 'with one_per_file' do
    let(:classes) do
      file = parse_ruby(<<~RUBY, file_path: '/app/controllers/foo_controller.rb')
        class FooController; end
        class BarController; end
      RUBY
      Rubyzen::Collections::ClassesCollection.new(file.classes)
    end

    it 'displays only the first violation from each file' do
      expect {
        expect(classes).to zen_empty(one_per_file: true)
      }.to raise_error(RSpec::Expectations::ExpectationNotMetError) { |error|
        expect(error.message).to include('FooController')
        expect(error.message).not_to include('BarController')
      }
    end
  end

  describe 'with allowlist' do
    let(:classes) do
      file = parse_ruby(<<~RUBY, file_path: '/app/controllers/foo_controller.rb')
        class FooController; end
        class BarController; end
      RUBY
      Rubyzen::Collections::ClassesCollection.new(file.classes)
    end

    it 'passes when all items are allowlisted' do
      expect(classes).to zen_empty(allowlist: ['FooController', 'BarController'])
    end

    it 'fails when there are non-allowlisted items' do
      expect {
        expect(classes).to zen_empty(allowlist: ['FooController'])
      }.to raise_error(RSpec::Expectations::ExpectationNotMetError, /violations/i)
    end

    it 'fails on stale allowlist entries' do
      expect {
        expect(classes).to zen_empty(allowlist: ['FooController', 'BarController', 'NonExistent'])
      }.to raise_error(RSpec::Expectations::ExpectationNotMetError, /stale/i)
    end
  end

  describe 'with baseline' do
    let(:classes) do
      file = parse_ruby(<<~RUBY, file_path: '/app/controllers/foo_controller.rb')
        class FooController; end
        class BarController; end
      RUBY
      Rubyzen::Collections::ClassesCollection.new(file.classes)
    end

    it 'passes when all items are in baseline' do
      expect(classes).to zen_empty(baseline: ['FooController', 'BarController'])
    end

    it 'fails on stale baseline entries' do
      expect {
        expect(classes).to zen_empty(baseline: ['FooController', 'BarController', 'OldClass'])
      }.to raise_error(RSpec::Expectations::ExpectationNotMetError, /stale/i)
    end
  end
end
