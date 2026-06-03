---
name: run-lint-rules
description: Run the sample project lint rules to verify that Rubyzen detects architectural violations. Use this skill when the user wants to run lint rules, verify that violations are detected, or test that a new lint rule works. Also trigger when the user says "run the lint rule", "check violations", or "test the sample project".
---

# Running Sample Project Lint Rules

The sample project (`sample_project/`) contains intentional architectural violations. Lint rule specs verify that Rubyzen correctly detects them.

## Run RSpec Lint Rules

```bash
bundle exec rspec sample_project/spec/
```

**Expected behavior:** Tests are expected to **fail** — the sample project intentionally contains violations to demonstrate Rubyzen's detection capabilities.

## Run a Specific Lint Rule

```bash
bundle exec rspec sample_project/spec/controllers/no_if_statements_in_controllers_lint_spec.rb
```

## Run Minitest Lint Rules

The sample project also has a parallel Minitest suite under `sample_project/test/` (using the `assert_zen_*` assertions). Run it with plain Ruby:

```bash
# All Minitest lint rules — single process, one aggregated summary
# (mirrors `bundle exec rspec sample_project/spec/`)
cd sample_project && bundle exec ruby -Itest -e 'Dir.glob("test/**/*_test.rb").sort.each { |f| require File.expand_path(f) }'

# A specific Minitest lint rule
cd sample_project && bundle exec ruby -Itest test/controllers/no_if_statements_in_controllers_test.rb
```

**Expected behavior:** same as RSpec — these are **expected to fail**, detecting the sample project's intentional violations.

## Lint Rule Structure

```
sample_project/
├── src/                          # Sample app with intentional violations
│   ├── controllers/
│   ├── models/
│   ├── presenters/
│   ├── repos/
│   ├── services/
│   ├── requests/
│   ├── tests/
│   └── config.rb
├── spec/                         # Lint rules as RSpec tests
│   ├── spec_helper.rb            # Shared context with collection helpers
│   ├── controllers/
│   ├── models/
│   ├── presenters/
│   ├── tests/
│   └── ...
└── test/                         # Lint rules as Minitest tests (parallel subset)
    ├── test_helper.rb            # LintTestCase base class with collection accessors
    ├── controllers/
    ├── models/
    ├── repos/
    └── database/
```

## Shared Context

Lint rules use a shared context that provides pre-built collections.

For RSpec, it's defined in `sample_project/spec/spec_helper.rb`:

```ruby
let(:project) { Rubyzen::Project.new([sample_src]) }
let(:controllers) { project.files.with_paths('src/controllers/').classes }
let(:models) { project.files.with_paths('src/models/').classes }
let(:services) { project.files.with_paths('src/services/').classes }
```

For Minitest, the equivalent is the `LintTestCase` base class in `sample_project/test/test_helper.rb`, which exposes the same collections as memoized methods (`controllers`, `models`, `services`, …) — subclass it in your lint rule and call them directly.
