require 'rubocop-ast'
require_relative '../declarations/file_declaration'

module Rubyzen
  module Parsers
    class ASTParser
      def parse_file(file_path)
        source = File.read(file_path)
        processed_source = RuboCop::AST::ProcessedSource.new(source, RUBY_VERSION.to_f, file_path)
        return nil unless processed_source.ast
        Rubyzen::Declarations::FileDeclaration.new(file_path, processed_source.ast)
      end
    end
  end
end
