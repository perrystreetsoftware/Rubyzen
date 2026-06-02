# Rubyzen

[![Gem Version](https://badge.fury.io/rb/rubyzen-lint.svg)](https://badge.fury.io/rb/rubyzen-lint)
[![CI](https://github.com/perrystreetsoftware/Rubyzen/actions/workflows/tests.yml/badge.svg)](https://github.com/perrystreetsoftware/Rubyzen/actions/workflows/tests.yml)
[![Docs](https://img.shields.io/badge/docs-yard-blue)](https://perrystreetsoftware.github.io/Rubyzen)

Rubyzen is an architectural linter for Ruby that allows you to write architectural lint rules as unit tests, inspired by [Konsist](https://github.com/LemonAppDev/konsist) (for Kotlin) and [Harmonize](https://github.com/perrystreetsoftware/Harmonize) (for Swift).

## Architectural linters in the era of AI-generated code

In the era of AI-generated code, architectural flaws and subtle bugs happen faster than ever. AI agents produce code that passes tests and looks reasonable but subtly violates your team's architecture. As more code is produced, faster, it becomes impractical for manual code reviews to catch all these violations.

Architectural lint rules act as deterministic guardrails. They catch the architectural or structural mistakes that AI introduces, such as calling the database from a presenter or performing business logic in a controller, before they get merged. And since they run as unit tests, they provide immediate feedback to the AI agents to fix their own code.

## Why Yet Another Linter?

Traditional linters such as [RuboCop](https://github.com/rubocop/rubocop) require dealing with the raw AST, which has a steep learning curve and makes rules hard to write, read, and maintain. Rubyzen abstracts away the AST details, providing a high-level API that allows developers to write lint rules in a more natural way — the same way we write tests.

## Advantages

- **Readable, Easy-to-Use API:** Rubyzen provides a high-level API to access files, classes, methods, parameters, and more, without having to deal with low-level AST operations.

- **Architectural Enforcement & Documentation:** By writing lint rules as tests, you can use the Given-When-Then style to enforce and document your architecture directly within the codebase.

- **Less Manual Reviews:** With architectural rules automatically enforced, code reviews can focus on complex issues instead of repeating the same architectural feedback.

- **AI-Friendly Feedback Loop:** When lint rules fail, the failure messages tell AI agents exactly what they violated and where, allowing them to self-correct their code.

## Setup

Add Rubyzen to your Gemfile's test group, alongside your test framework.

```ruby
group :test do
  gem 'rubyzen-lint'
  # gem 'rspec'      # if you use RSpec (or rspec-rails)
  # gem 'minitest'   # if you use Minitest
end
```

Then run `bundle install`.

Rubyzen auto-discovers your project structure (`app/`, `lib/`, `src/`, `spec/`) from your project root. If you need to lint other directories (e.g., `config/`, `db/`), see [Custom Paths](#custom-paths) below.

## Write your first set of lint rules

Create a spec file anywhere in your project (e.g., `spec/architecture/sample_spec.rb`) and start enforcing your architecture:

```ruby
require 'rubyzen/rspec'

RSpec.describe 'Architecture rules' do
  let(:project) { Rubyzen::Project.new }
  let(:controllers) { project.files.with_paths('app/controllers/').classes }
  let(:presenters) { project.files.with_paths('app/presenters/').classes }

  it 'controllers do not call ActiveRecord directly' do
    expect(controllers.all_methods.call_sites.with_name('where')).to zen_empty
  end

  it 'controllers inherit from ApplicationController' do
    expect(controllers).to zen_true { |c| c.superclass_name == 'ApplicationController' }
  end

  it 'presenters do not depend on repositories' do
    expect(presenters.all_methods.call_sites).to zen_false { |cs|
      cs.receiver&.end_with?('Repository')
    }
  end
end
```

You can find more sample lint rules in the [`sample_project/spec/`](sample_project/spec/) directory.

## Using Minitest

If you use Minitest instead of RSpec, replace `require 'rubyzen/rspec'` with `require 'rubyzen/minitest'` and use the equivalent Minitest assertions:

```ruby
require 'rubyzen/minitest'

class ArchitectureTest < Minitest::Test
  def controllers = Rubyzen::Project.new.files.with_paths('app/controllers/').classes

  def test_controllers_do_not_call_active_record_directly
    assert_zen_empty(controllers.all_methods.call_sites.with_name('where'))
  end
end
```

## Matchers and assertions

Rubyzen provides three checks for your architectural lint rules:

| Using RSpec | Using Minitest | Checks that |
|---|---|---|
| `zen_empty` | `assert_zen_empty(collection)` | the collection is empty |
| `zen_true { \|item\| }` | `assert_zen_true(collection) { \|item\| }` | the block returns true for every element |
| `zen_false { \|item\| }` | `assert_zen_false(collection) { \|item\| }` | the block returns false for every element |

All three accept an `allowlist:` of exceptions that are permanently exempt from the rule, a `baseline:` of known existing violations (technical debt) to fix over time, and a custom failure message.

## Run your lint rules

```bash
# If you use RSpec:
bundle exec rspec spec/architecture/

# If you use Minitest:
bundle exec rake lint              # via a Rake task
bin/rails test test/architecture   # via the Rails test runner
```

## Custom Paths

By default, `Rubyzen::Project.new` scans `app/`, `lib/`, `src/`, and `spec/`. If you need to lint other directories (e.g., `config/`, `db/`), add them explicitly, otherwise those files won't be scanned and queries against them will return empty results.

```ruby
# In your spec file — scope to specific directories
project = Rubyzen::Project.new(['app/models', 'app/controllers'])

# Or in spec/spec_helper.rb — configure globally for all specs
Rubyzen.configure do |config|
  config.paths = ['app', 'lib', 'config']
end
```

## CI Integration

Add a step to your existing CI workflow to run your lint rules automatically when a PR is opened:

```yaml
- name: Run architecture lint rules
  # If you use RSpec:
  run: bundle exec rspec spec/architecture/
  
  # If you use Minitest:
  # run: bundle exec rake lint
```

## AI Agent Skills

Rubyzen includes agent skills in `.claude/skills/` (also symlinked at `.github/skills/`) that work with both Claude Code and GitHub Copilot:

| Skill | Purpose |
|---|---|
| `write-lint-rule` | Write an architectural lint rule using the Rubyzen API |
| `run-lint-rules` | Run sample project lint rules and verify the violations are detected |
| `expand-rubyzen` | Add a new Rubyzen API (Declaration + Provider + Collection) |
| `add-rubyzen-tests` | Write unit tests for Rubyzen's own components |
| `run-tests` | Run Rubyzen's unit test suite |

## Contributing

Contributions are welcome! See [CONTRIBUTING.md](CONTRIBUTING.md) for instructions on setting up the project, enhancing the API, and adding tests.

## Perry Street Software is hiring

If you are a Ruby or DevOps engineer excited about [application architecture](https://itnext.io/a-visual-history-of-web-api-architecture-c36044df2ac7) on a platform running at very large scale, check out our [careers](https://www.perrystreet.com/careers) page! Our company has written extensively about our technical approach on the [Perry Street Software Engineering Blog](https://medium.com/perry-street-software-engineering).
