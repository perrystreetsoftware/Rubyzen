require 'rubocop-ast'

module ParseHelper
  def parse_ruby(source, file_path: 'test.rb')
    processed = RuboCop::AST::ProcessedSource.new(source, RUBY_VERSION.to_f, file_path)
    Rubyzen::Declarations::FileDeclaration.new(file_path, processed.ast)
  end
end

RSpec.configure do |config|
  config.include ParseHelper
end
