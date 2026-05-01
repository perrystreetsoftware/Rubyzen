require 'rubocop-ast'
require 'zeitwerk'

loader = Zeitwerk::Loader.for_gem
loader.setup

# Load RSpec matchers manually since they don't follow class/module naming conventions
require_relative 'rubyzen/matchers/be_empty_matcher'
require_relative 'rubyzen/matchers/be_empty_with_exceptions_matcher'
require_relative 'rubyzen/matchers/be_true_matcher'
require_relative 'rubyzen/matchers/be_false_matcher'

# Rubyzen is a Ruby architectural linter that lets you write lint rules as RSpec tests.
# It wraps RuboCop AST to provide a high-level, fluent API for enforcing architectural
# rules across a codebase.
#
# @example Basic usage
#   project = Rubyzen::Project.new(["/path/to/src", "/path/to/spec"])
#   controllers = project.files.with_paths("controllers/").classes
#
#   # Assert controllers don't call ActiveRecord directly
#   expect(controllers.all_methods.call_sites.with_name("where")).to be_empty
#
# @example Using environment variable
#   # Set RUBYZEN_PROJECT_PATHS="/path/to/src,/path/to/spec"
#   project = Rubyzen::Project.new  # reads from env var
#
module Rubyzen
  # Returns the global configuration, reading from the +RUBYZEN_PROJECT_PATHS+ environment variable.
  #
  # @return [Configuration]
  # @raise [RuntimeError] if +RUBYZEN_PROJECT_PATHS+ is not set or contains invalid paths
  def self.configuration
    @configuration ||= Configuration.new
  end

  # Reads and validates project paths from the +RUBYZEN_PROJECT_PATHS+ environment variable.
  #
  # @example
  #   ENV['RUBYZEN_PROJECT_PATHS'] = "/app/src,/app/spec"
  #   config = Rubyzen::Configuration.new
  #   config.project_paths #=> ["/app/src", "/app/spec"]
  #
  class Configuration
    # @return [Array<String>] absolute paths to directories to analyze
    attr_reader :project_paths

    def initialize
      load_configuration
    end

    private

    def load_configuration
      unless ENV['RUBYZEN_PROJECT_PATHS']
        raise 'RUBYZEN_PROJECT_PATHS environment variable is required.'
      end

      @project_paths = ENV['RUBYZEN_PROJECT_PATHS'].split(',').map(&:strip).reject(&:empty?)

      @project_paths.each do |path|
        unless Dir.exist?(path)
          raise "Directory not found: #{path}. Please ensure all paths in RUBYZEN_PROJECT_PATHS exist."
        end
      end
    end
  end
end
