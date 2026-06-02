require_relative 'lib/rubyzen/version'

Gem::Specification.new do |spec|
  spec.name          = 'rubyzen-lint'
  spec.version       = Rubyzen::VERSION
  spec.authors       = ['Perry Street Software']
  spec.summary       = 'Architectural linter for Ruby — write lint rules as unit tests'
  spec.description   = 'Rubyzen is a modern linter for Ruby that allows you to write architectural ' \
                       'lint rules as unit tests. In the era of AI-generated code, it provides your ' \
                       'team with deterministic guardrails to keep your codebase clean, maintainable, ' \
                       'and consistent as it grows.'
  spec.homepage      = 'https://github.com/perrystreetsoftware/Rubyzen'
  spec.license       = 'Apache-2.0'

  spec.required_ruby_version = '>= 3.1'

  spec.files = Dir.glob(%w[lib/**/*.rb rubyzen-lint.gemspec LICENSE README.md CHANGELOG.md])
  spec.require_paths = ['lib']

  spec.add_dependency 'rubocop-ast', '~> 1.26'
  spec.add_dependency 'zeitwerk', '~> 2.6'

  spec.add_development_dependency 'rspec', '~> 3.12'
  spec.add_development_dependency 'minitest', '>= 5.0', '< 7.0'
  spec.add_development_dependency 'rake', '~> 13.0'

  spec.metadata = {
    'source_code_uri' => 'https://github.com/perrystreetsoftware/Rubyzen',
    'bug_tracker_uri' => 'https://github.com/perrystreetsoftware/Rubyzen/issues',
    'documentation_uri' => 'https://perrystreetsoftware.github.io/Rubyzen',
    'changelog_uri' => 'https://github.com/perrystreetsoftware/Rubyzen/blob/main/CHANGELOG.md'
  }
end
