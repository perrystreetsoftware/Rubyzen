require 'rubocop-ast'
require 'require_all'
require_all 'lib/rubyzen'
require 'yaml'

module Rubyzen
  class Configuration
    attr_accessor :project_root_path, :only_changed_files

    def initialize
      config_path = File.expand_path('../../.rubyzen.yaml', __FILE__)
      if File.exist?(config_path)
        yaml_config = YAML.load_file(config_path)
        @project_root_path = yaml_config['project_path']
        @only_changed_files = yaml_config['only_changed_files']
      else
        raise ".rubyzen.yaml not found in the root of the project"
      end
    end
  end

  def self.configuration
    @configuration ||= Configuration.new
  end
end
