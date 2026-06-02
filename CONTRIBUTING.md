# Contributing to Rubyzen

## Setup

```bash
git clone https://github.com/perrystreetsoftware/Rubyzen.git
cd Rubyzen
bundle install
```

## Running Tests

Rubyzen includes both an RSpec adapter and a Minitest adapter, each with its own unit test suite.

```bash
# Rubyzen's unit tests (both test suites)
bundle exec rake

# Or run them individually
bundle exec rspec spec
bundle exec rake test

# Sample project lint rules (expected to fail — intentional violations)
# Using RSpec adapter
bundle exec rspec sample_project/spec/
# Using Minitest adapter
cd sample_project && for f in test/**/*_test.rb; do bundle exec ruby -Itest "$f"; done
```

## Project Structure

- **`lib/rubyzen/`** — Source code (declarations, collections, providers, matchers, assertions, parsers, cache). `core.rb` is the framework-agnostic core loaded by `require 'rubyzen'`; the adapters are `rubyzen/rspec.rb` (RSpec matchers) and `rubyzen/minitest.rb` (Minitest assertions).
- **`spec/`** — RSpec unit tests for Rubyzen's own API
- **`test/`** — Minitest unit tests for Rubyzen's own API
- **`sample_project/`** — Sample app with intentional violations and lint rules (RSpec in `spec/`, Minitest in `test/`) demonstrating Rubyzen

## Making Changes

1. Fork the repository
2. Create a branch (`git checkout -b my-change`)
3. Make your changes
4. Run the tests (`bundle exec rake` — runs both the RSpec and Minitest test suites)
5. Commit and push
6. Open a Pull Request

## Guidelines

- Follow existing code patterns (Declarations, Collections, Providers architecture)
- Add tests for new features
- Keep the API surface minimal and consistent
- Use YARD comments on public methods
