require 'rubocop-ast'
require 'rspec'
require 'zeitwerk'

loader = Zeitwerk::Loader.for_gem
loader.ignore("#{__dir__}/rubyzen/matchers")
loader.ignore("#{__dir__}/rubyzen/rspec")
loader.setup

require_relative 'rubyzen/matchers/matcher_helpers'
require_relative 'rubyzen/matchers/zen_empty_matcher'
require_relative 'rubyzen/matchers/zen_true_matcher'
require_relative 'rubyzen/matchers/zen_false_matcher'

# Rubyzen is a Ruby architectural linter that lets you write lint rules as RSpec tests.
# It wraps RuboCop AST to provide a high-level, easy-to-use API for enforcing architectural
# rules across a codebase.
#
# @example Basic usage
#   project = Rubyzen::Project.new(["/path/to/src", "/path/to/spec"])
#   controllers = project.files.with_paths("controllers/").classes
#
#   # Assert controllers don't call ActiveRecord directly
#   expect(controllers.all_methods.call_sites.with_name("where")).to zen_empty
#
# @example Using auto-discovery (from project root)
#   project = Rubyzen::Project.new  # scans app/, lib/, src/, spec/ automatically
#
module Rubyzen
  # Base error class for all Rubyzen errors.
  class Error < StandardError; end

  # Raised when a Ruby file cannot be parsed.
  class ParseError < Error; end

  # Yields the global configuration for customization.
  #
  # @example
  #   Rubyzen.configure do |config|
  #     config.paths = ['app', 'lib']
  #   end
  def self.configure
    yield(configuration)
  end

  # Returns the global configuration instance.
  #
  # @return [Configuration]
  def self.configuration
    @configuration ||= Configuration.new
  end

  # Holds project path configuration with auto-discovery support.
  #
  # Resolution order:
  # 1. Explicit paths via {#paths=} (set via +Rubyzen.configure+)
  # 2. Auto-discovery of +app/+, +lib/+, +src/+, +spec/+ from +Dir.pwd+
  #
  # @example
  #   Rubyzen.configure { |c| c.paths = ['app/models', 'app/controllers'] }
  #   Rubyzen.configuration.project_paths #=> ["/full/path/app/models", "/full/path/app/controllers"]
  #
  class Configuration
    # Sets explicit paths to scan.
    # Relative paths are resolved against +Dir.pwd+.
    #
    # @param value [Array<String>] directories to analyze
    attr_writer :paths

    # Returns the resolved project paths.
    #
    # @return [Array<String>] absolute paths to directories to analyze
    def project_paths
      resolve_paths(@paths) || auto_discover_paths
    end

    private

    def resolve_paths(paths)
      return nil unless paths

      root = Dir.pwd
      paths.map do |path|
        File.expand_path(path, root)
      end
    end

    def auto_discover_paths
      root = Dir.pwd
      candidates = %w[app lib src spec].map { |d| File.join(root, d) }
      paths = candidates.select { |d| Dir.exist?(d) }
      paths = [root] if paths.empty?
      paths
    end
  end
end
