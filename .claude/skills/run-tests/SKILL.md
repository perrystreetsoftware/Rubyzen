---
name: run-tests
description: Run Rubyzen's unit test suite. Use this skill when the user wants to run tests, verify changes, check if an API is broken, or confirm that specs pass. Also trigger when the user says "run specs", "run the tests", "does it pass?", or "check the tests".
---

# Running Rubyzen Unit Tests

Unit tests verify the correctness of Rubyzen's own API — declarations, providers, collections, and matchers.

## Run All Tests

```bash
bundle exec rspec spec/
```

## Run a Specific File

```bash
bundle exec rspec spec/declarations/class_declaration_spec.rb
```

## Run a Specific Category

```bash
# All declaration tests
bundle exec rspec spec/declarations/

# All collection tests
bundle exec rspec spec/collections/

# All matcher tests
bundle exec rspec spec/matchers/

# All provider tests (covered within declaration specs)
bundle exec rspec spec/declarations/
```

## Test Structure

```
spec/
├── spec_helper.rb              # Loads Rubyzen, includes parse helper
├── support/
│   └── parse_helper.rb         # parse_ruby helper for inline snippets
├── fixtures/                   # Small .rb files for Project path tests
├── declarations/               # One spec per declaration type
├── collections/                # One spec per collection type
├── matchers/                   # One spec per matcher
├── project_spec.rb             # Project class tests
└── cache/
    └── parse_cache_spec.rb     # Caching behavior tests
```

## Interpreting Failures

- Matcher specs test the custom RSpec matchers (`be_empty`, `be_true`, `be_false`)
- Declaration specs test that AST nodes are correctly wrapped and exposed
- Collection specs test filtering, chaining, and bridge methods
- If a test fails after adding a new concept, check that providers are included in the right declarations and that bridge methods return the correct collection type
