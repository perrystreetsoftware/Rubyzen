require 'rubocop-ast'
require 'require_all'
# require_all 'lib/rubyzen'
require_relative './rubyzen/class_analyzer.rb'
require_relative './rubyzen/project.rb'
require_relative './rubyzen/methods_collection.rb'
require_relative './rubyzen/classes_collection.rb'
require_relative './rubyzen/matchers/matcher_helpers.rb'
require_relative './rubyzen/matchers/call_method.rb'
require 'yaml'

module Rubyzen
  class Configuration
    attr_accessor :project_root_path

    def initialize
      config_path = File.expand_path('../../.rubyzen.yaml', __FILE__)
      if File.exist?(config_path)
        yaml_config = YAML.load_file(config_path)
        @project_root_path = yaml_config['project_path']
      else
        raise ".rubyzen.yaml not found in the root of the project"
      end
    end
  end

  def self.configuration
    @configuration ||= Configuration.new
  end
end
