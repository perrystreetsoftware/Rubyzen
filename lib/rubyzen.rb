require 'rubocop-ast'
require 'require_all'
require_all 'lib/rubyzen'

module Rubyzen
  def self.configuration
    @configuration ||= Configuration.new
  end

  class Configuration
    attr_reader :project_root_path

    def initialize
      load_configuration
    end

    private

    def load_configuration
      project_path = ENV['RUBYZEN_PROJECT_PATH']

      if project_path.nil? || project_path.empty?
        raise "RUBYZEN_PROJECT_PATH environment variable is required. Please set it to the absolute path of the directory to analyze."
      end

      unless Dir.exist?(project_path)
        raise "Directory not found: #{project_path}. Please ensure RUBYZEN_PROJECT_PATH points to a valid directory."
      end

      @project_root_path = project_path
    end
  end
end
