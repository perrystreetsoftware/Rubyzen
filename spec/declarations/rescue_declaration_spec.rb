require 'spec_helper'

RSpec.describe Rubyzen::Declarations::RescueDeclaration do
  def rescues_from(source)
    file = parse_ruby(<<~RUBY)
      class Foo
        def bar
          #{source}
        end
      end
    RUBY
    file.classes.first.instance_methods.first.rescues
  end

  describe '#exception_types' do
    it 'returns the rescued exception class' do
      rescues = rescues_from("begin\n  something\nrescue ArgumentError\n  handle\nend")
      expect(rescues.first.exception_types).to eq(['ArgumentError'])
    end

    it 'returns multiple exception types' do
      rescues = rescues_from("begin\n  something\nrescue ArgumentError, TypeError\n  handle\nend")
      expect(rescues.first.exception_types).to eq(%w[ArgumentError TypeError])
    end

    it 'returns StandardError for bare rescue' do
      rescues = rescues_from("begin\n  something\nrescue\n  handle\nend")
      expect(rescues.first.exception_types).to eq(['StandardError'])
    end
  end

  describe '#class_name' do
    it 'returns the enclosing class name' do
      rescues = rescues_from("begin\n  x\nrescue\n  y\nend")
      expect(rescues.first.class_name).to eq('Foo')
    end
  end

  describe '#file_path' do
    it 'returns the file path' do
      file = parse_ruby(<<~RUBY, file_path: '/app/foo.rb')
        class Foo
          def bar
            begin
              x
            rescue
              y
            end
          end
        end
      RUBY

      rescue_decl = file.classes.first.instance_methods.first.rescues.first
      expect(rescue_decl.file_path).to eq('/app/foo.rb')
    end
  end

  describe '#line' do
    it 'returns the line number' do
      rescues = rescues_from("begin\n  x\nrescue\n  y\nend")
      expect(rescues.first.line).to be_a(Integer)
    end
  end
end
