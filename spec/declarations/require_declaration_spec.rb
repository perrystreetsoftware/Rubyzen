require 'spec_helper'

RSpec.describe Rubyzen::Declarations::RequireDeclaration do
  def requires_from(source)
    parse_ruby("#{source}\nx = 1").requires
  end

  describe '#name' do
    it 'returns "require" for require calls' do
      reqs = requires_from('require "json"')
      expect(reqs.first.name).to eq('require')
    end

    it 'returns "require_relative" for require_relative calls' do
      reqs = requires_from('require_relative "helper"')
      expect(reqs.first.name).to eq('require_relative')
    end
  end

  describe '#required_path' do
    it 'returns the required path' do
      reqs = requires_from('require "json"')
      expect(reqs.first.required_path).to eq('json')
    end
  end

  describe '#require?' do
    it 'returns true for require' do
      reqs = requires_from('require "json"')
      expect(reqs.first.require?).to be true
      expect(reqs.first.require_relative?).to be false
    end
  end

  describe '#require_relative?' do
    it 'returns true for require_relative' do
      reqs = requires_from('require_relative "helper"')
      expect(reqs.first.require_relative?).to be true
      expect(reqs.first.require?).to be false
    end
  end

  describe '#load?' do
    it 'returns true for load calls' do
      reqs = requires_from('load "config.rb"')
      expect(reqs.first.load?).to be true
    end
  end

  describe '#file_path' do
    it 'returns the file path' do
      file = parse_ruby("require \"json\"\nx = 1", file_path: '/app/init.rb')
      expect(file.requires.first.file_path).to eq('/app/init.rb')
    end
  end

  describe '#line' do
    it 'returns the line number' do
      reqs = requires_from('require "json"')
      expect(reqs.first.line).to eq(1)
    end
  end
end
