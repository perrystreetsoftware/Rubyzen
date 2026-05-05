require 'rubocop-ast'

module Rubyzen
  module Parsers
    # Singleton parser that converts Ruby source files into Rubyzen declarations
    # using RuboCop's AST processing. Results are cached via {Cache::ParseCache}.
    class ASTParser
      # Returns the singleton instance of the parser.
      #
      # @return [ASTParser]
      def self.instance
        @instance ||= new
      end

      def initialize
        @cache = Rubyzen::Cache::ParseCache.new
      end

      # Parses a Ruby source file and returns its declaration, using the cache.
      #
      # @param file_path [String] absolute path to the Ruby file
      # @return [Declarations::FileDeclaration, nil] the parsed file declaration, or nil if unparseable
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
