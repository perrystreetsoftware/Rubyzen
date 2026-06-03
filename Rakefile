require 'rake/testtask'
require 'rspec/core/rake_task'

# Minitest unit tests (test/**/*_test.rb).
Rake::TestTask.new(:test) do |t|
  t.libs << 'test' << 'lib'
  t.test_files = FileList['test/**/*_test.rb']
  t.warning = false
end

# RSpec unit tests (spec/**/*_spec.rb).
RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = 'spec/**/*_spec.rb'
end

task default: %i[spec test]
