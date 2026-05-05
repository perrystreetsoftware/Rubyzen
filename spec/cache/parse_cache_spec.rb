require 'spec_helper'
require 'tempfile'

RSpec.describe Rubyzen::Cache::ParseCache do
  let(:cache) { Rubyzen::Cache::ParseCache.new }

  it 'returns the parsed result for a file' do
    Tempfile.create(['test', '.rb']) do |f|
      f.write('class Foo; end')
      f.flush

      result = cache.fetch_or_parse(f.path) do
        Rubyzen::Parsers::ASTParser.instance.parse_file(f.path)
      end

      expect(result).to be_a(Rubyzen::Declarations::FileDeclaration)
      expect(result.classes.first.name).to eq('Foo')
    end
  end

  it 'returns cached result on second call with same content' do
    Tempfile.create(['test', '.rb']) do |f|
      f.write('class Foo; end')
      f.flush

      parse_count = 0
      2.times do
        cache.fetch_or_parse(f.path) do
          parse_count += 1
          Rubyzen::Parsers::ASTParser.instance.parse_file(f.path)
        end
      end

      expect(parse_count).to eq(1)
    end
  end

  it 're-parses when file content changes' do
    Tempfile.create(['test', '.rb']) do |f|
      f.write('class Foo; end')
      f.flush

      result1 = cache.fetch_or_parse(f.path) do
        Rubyzen::Parsers::ASTParser.instance.parse_file(f.path)
      end

      f.reopen(f.path, 'w')
      f.write('class Bar; end')
      f.flush

      result2 = cache.fetch_or_parse(f.path) do
        Rubyzen::Parsers::ASTParser.instance.parse_file(f.path)
      end

      expect(result1.classes.first.name).to eq('Foo')
      expect(result2.classes.first.name).to eq('Bar')
    end
  end
end
