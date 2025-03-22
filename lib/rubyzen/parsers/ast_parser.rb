require 'rubocop-ast'
require_relative '../declarations/file_declaration'
require_relative '../cache/parse_cache'

module Rubyzen
  module Parsers
    class ASTParser
      def self.instance
        @instance ||= new
      end

      def initialize
        @cache = Rubyzen::Cache::ParseCache.new
      end

      def parse_file(file_path)
        @cache.fetch_or_parse(file_path) do
          source = File.read(file_path)
          processed_source = RuboCop::AST::ProcessedSource.new(source, RUBY_VERSION.to_f, file_path)
          next nil unless processed_source.ast
          Rubyzen::Declarations::FileDeclaration.new(file_path, processed_source.ast)
        end
      end
    end
  end
end
