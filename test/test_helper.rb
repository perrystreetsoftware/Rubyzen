require 'rubyzen/minitest'
require 'minitest/autorun'
require 'rubocop-ast'

# Parses a Ruby source string into a FileDeclaration for use in unit tests.
# Mirrors the spec/support/parse_helper.rb.
module ParseHelper
  def parse_ruby(source, file_path: 'test.rb')
    processed = RuboCop::AST::ProcessedSource.new(source, RUBY_VERSION.to_f, file_path)
    Rubyzen::Declarations::FileDeclaration.new(file_path, processed.ast)
  end
end
