require 'spec_helper'

RSpec.describe Rubyzen::Declarations::BlockDeclaration do
  def blocks_from(source)
    file = parse_ruby(<<~RUBY)
      class Foo
        def bar
          #{source}
        end
      end
    RUBY
    file.classes.first.instance_methods.first.blocks
  end

  describe '#name and #method_name' do
    it 'returns the method the block is passed to' do
      blocks = blocks_from('items.each { |i| puts i }')
      expect(blocks.first.name).to eq('each')
      expect(blocks.first.method_name).to eq('each')
    end
  end

  describe '#call_sites' do
    it 'returns call sites within the block' do
      blocks = blocks_from('[1].map { |x| x.to_s }')
      sites = blocks.first.call_sites
      expect(sites.map(&:method_name)).to include('to_s')
    end
  end

  describe '#lines_of_code' do
    it 'returns the line count of the block' do
      blocks = blocks_from("items.each do |i|\n  puts i\nend")
      expect(blocks.first.lines_of_code).to be >= 1
    end
  end

  describe '#source_code' do
    it 'returns the source code of the block' do
      blocks = blocks_from('items.each { |i| puts i }')
      expect(blocks.first.source_code).to include('each')
    end
  end

  describe '#rescues' do
    it 'returns rescue declarations within the block' do
      file = parse_ruby(<<~RUBY)
        class Foo
          def bar
            items.each do |i|
              begin
                i.save!
              rescue ActiveRecord::RecordInvalid
                handle
              end
            end
          end
        end
      RUBY

      blocks = file.classes.first.instance_methods.first.blocks
      expect(blocks.first.rescues.size).to eq(1)
    end
  end

  describe '#raises' do
    it 'returns raise declarations within the block' do
      file = parse_ruby(<<~RUBY)
        class Foo
          def bar
            items.each do |i|
              raise ArgumentError, "bad"
            end
          end
        end
      RUBY

      blocks = file.classes.first.instance_methods.first.blocks
      expect(blocks.first.raises.size).to eq(1)
    end
  end

  describe '#class_name' do
    it 'returns the enclosing class name' do
      blocks = blocks_from('items.each { |i| i }')
      expect(blocks.first.class_name).to eq('Foo')
    end
  end

  describe '#file_path' do
    it 'returns the file path' do
      file = parse_ruby(<<~RUBY, file_path: '/app/foo.rb')
        class Foo
          def bar
            items.each { |i| i }
          end
        end
      RUBY

      block = file.classes.first.instance_methods.first.blocks.first
      expect(block.file_path).to eq('/app/foo.rb')
    end
  end
end
