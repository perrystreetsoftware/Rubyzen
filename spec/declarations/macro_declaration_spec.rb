require 'spec_helper'

RSpec.describe Rubyzen::Declarations::MacroDeclaration do
  def macros_from(source)
    file = parse_ruby(<<~RUBY)
      class Foo
        #{source}
      end
    RUBY
    file.classes.first.macros
  end

  describe '#name' do
    it 'returns the macro name' do
      macros = macros_from('validates_required :name')
      expect(macros.first.name).to eq('validates_required')
    end
  end

  describe '#symbols' do
    it 'returns symbol arguments' do
      macros = macros_from('validates_required :name, :email')
      expect(macros.first.symbols).to eq([:name, :email])
    end
  end

  describe '#strings' do
    it 'returns string arguments' do
      macros = macros_from('some_macro "path/to/file"')
      expect(macros.first.strings).to eq(['path/to/file'])
    end
  end

  describe '#keyword_args' do
    it 'returns keyword argument keys' do
      macros = macros_from('belongs_to :user, foreign_key: :user_id, optional: true')
      expect(macros.first.keyword_args).to contain_exactly(:foreign_key, :optional)
    end
  end

  describe '#receiver' do
    it 'returns the receiver constant name' do
      macros = macros_from('Config.setting :timeout')
      macro = macros.filter { |m| m.name == 'setting' }.first
      expect(macro&.receiver).to eq('Config') if macro
    end

    it 'returns nil when no receiver' do
      macros = macros_from('validates_required :name')
      expect(macros.first.receiver).to be_nil
    end
  end

  describe '#source_code' do
    it 'returns the source' do
      macros = macros_from('validates_required :name')
      expect(macros.first.source_code).to include('validates_required')
    end
  end

  describe '#class_name' do
    it 'returns the enclosing class name' do
      macros = macros_from('validates_required :name')
      expect(macros.first.class_name).to eq('Foo')
    end
  end
end
