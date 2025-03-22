require_relative 'matcher_helpers'

RSpec::Matchers.define :have_corresponding_spec_files_in do |spec_root, custom_message=nil|
  include Rubyzen::Matchers::MatcherHelpers

  match do |source_files|
    @custom_message = custom_message
    @spec_root = spec_root
    @offenders = []

    source_files.each do |source_file|
      file_path = source_file.is_a?(String) ? source_file : source_file.path
      spec_file = corresponding_spec_file(file_path)
      unless File.exist?(spec_file)
        @offenders << "#{file_path} -> expected: #{spec_file}"
      end
    end

    @offenders.empty?
  end

  failure_message do |_source_files|
    message_for_failure("Expected all files to have corresponding specs in #{@spec_root}, but some were missing.")
  end

  failure_message_when_negated do |_source_files|
    message_for_failure("Expected no corresponding spec files in #{@spec_root}, but found some.")
  end

  def corresponding_spec_file(source_file_path)
    relative_path = source_file_path.split('src/').last
    spec_filename = relative_path.sub(/\.rb$/, '_spec.rb')
    project_root = File.dirname(Rubyzen.configuration.project_root_path)
    File.join(project_root, @spec_root, spec_filename)
  end
end
