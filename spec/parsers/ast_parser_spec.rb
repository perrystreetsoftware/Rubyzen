require 'spec_helper'
require 'tempfile'

RSpec.describe Rubyzen::Parsers::ASTParser do
  describe '.instance' do
    it 'returns the same instance' do
      expect(Rubyzen::Parsers::ASTParser.instance).to be(Rubyzen::Parsers::ASTParser.instance)
    end
  end

  describe '#parse_file' do
    it 'returns a FileDeclaration for valid Ruby' do
      Tempfile.create(['valid', '.rb']) do |f|
        f.write("class Foo; end\nx = 1")
        f.flush

        result = Rubyzen::Parsers::ASTParser.instance.parse_file(f.path)
        expect(result).to be_a(Rubyzen::Declarations::FileDeclaration)
        expect(result.classes.first.name).to eq('Foo')
      end
    end

    it 'returns nil for unparseable Ruby' do
      Tempfile.create(['invalid', '.rb']) do |f|
        f.write('def class end end end {{{')
        f.flush

        result = Rubyzen::Parsers::ASTParser.instance.parse_file(f.path)
        expect(result).to be_nil
      end
    end
  end
end
