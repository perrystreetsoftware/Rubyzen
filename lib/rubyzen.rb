require 'rubocop-ast'
require 'require_all'
require_all 'lib/rubyzen'
require 'yaml'

module Rubyzen
  def self.configuration
    @configuration ||= Configuration.new
  end

  class Configuration
    attr_reader :project_root_path, :rules

    def initialize
      load_configuration
    end

    private

    def load_configuration
      config_file = '.rubyzen.yaml'

      unless File.exist?(config_file)
        raise "Configuration file #{config_file} not found"
      end

      yaml_config = YAML.load_file(config_file)

      @project_root_path = yaml_config['project_path'] || './sample_project/src'
      @rules = yaml_config['rules'] || {}

      # Handle case where target project might not be mounted
      unless Dir.exist?(@project_root_path)
        target_project = ENV['RUBYZEN_TARGET_PROJECT']

        if target_project.nil? || target_project.empty?
          puts "Error: RUBYZEN_TARGET_PROJECT environment variable not set."
          puts "Please set it to specify which project to lint:"
          puts "  export RUBYZEN_TARGET_PROJECT=YourProjectName"
          puts ""
          puts "Falling back to sample project..."
        else
          puts "Warning: Target project '#{target_project}' not found at #{@project_root_path}"
          puts "Make sure:"
          puts "  1. The project exists at: ../#{target_project}"
          puts "  2. The dev container has been rebuilt after setting RUBYZEN_TARGET_PROJECT"
          puts "  3. The project has a 'src' directory"
          puts ""
          puts "Falling back to sample project..."
        end

        # Fallback to sample project
        fallback_path = './sample_project/src'
        if Dir.exist?(fallback_path)
          @project_root_path = fallback_path
        else
          raise "Neither target project nor sample project found! Please check your configuration."
        end
      end
    end
  end
end
