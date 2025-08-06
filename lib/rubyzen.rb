require 'rubocop-ast'
require 'require_all'
require_all 'lib/rubyzen'

module Rubyzen
  def self.configuration
    @configuration ||= Configuration.new
  end

  class Configuration
    attr_reader :project_paths

    def initialize
      load_configuration
    end

    private

    def load_configuration
      unless ENV['RUBYZEN_PROJECT_PATHS']
        raise 'RUBYZEN_PROJECT_PATHS environment variable is required.'
      end

      @project_paths = ENV['RUBYZEN_PROJECT_PATHS'].split(':').map(&:strip).reject(&:empty?)

      @project_paths.each do |path|
        unless Dir.exist?(path)
          raise "Directory not found: #{path}. Please ensure all paths in RUBYZEN_PROJECT_PATHS exist."
        end
      end
    end
  end
end
