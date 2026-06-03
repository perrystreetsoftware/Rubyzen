# Minitest equivalent of sample_project/spec/spec_helper.rb.
#
# Loads Rubyzen's Minitest adapter and provides a `LintTestCase` base class
# whose memoized accessors mirror the shared `let` collections from the RSpec
# `project_config` shared context.
require 'rubyzen/minitest'
require 'minitest/autorun'

SAMPLE_SRC = File.expand_path('../src', __dir__)

# Base class for the sample-project lint rules written with Minitest.
class LintTestCase < Minitest::Test
  def project
    @project ||= Rubyzen::Project.new([SAMPLE_SRC])
  end

  def files
    @files ||= project.files.with_paths('src/')
  end

  def all_classes
    @all_classes ||= files.classes
  end

  def all_modules
    @all_modules ||= files.modules
  end

  def controllers
    @controllers ||= project.files.with_paths('src/controllers/').classes
  end

  def presenters
    @presenters ||= project.files.with_paths('src/presenters/').classes
  end

  def services
    @services ||= project.files.with_paths('src/services/').classes
  end

  def requests
    @requests ||= project.files.with_paths('src/requests/').classes
  end

  def models_files
    @models_files ||= project.files.with_paths('src/models/')
  end

  def models
    @models ||= models_files.classes
  end

  def repos
    @repos ||= project.files.with_paths('src/repos/').without_paths('/spec/').classes
  end
end
