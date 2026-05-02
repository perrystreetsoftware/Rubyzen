---
name: run-lint-rules
description: Run the sample project lint rules to verify that Rubyzen detects architectural violations. Use this skill when the user wants to run lint rules, verify that violations are detected, or test that a new lint rule works. Also trigger when the user says "run the lint rule", "check violations", or "test the sample project".
---

# Running Sample Project Lint Rules

The sample project (`sample_project/`) contains intentional architectural violations. Lint rule specs verify that Rubyzen correctly detects them.

## Run All Lint Rules

```bash
bundle exec rspec sample_project/spec/
```

**Expected behavior:** Tests are expected to **fail** — the sample project intentionally contains violations to demonstrate Rubyzen's detection capabilities.

## Run a Specific Lint Rule

```bash
bundle exec rspec sample_project/spec/controllers/no_if_statements_in_controllers_lint_spec.rb
```

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
└── spec/                         # Lint rules as RSpec tests
    ├── spec_helper.rb            # Shared context with collection helpers
    ├── controllers/
    ├── models/
    ├── presenters/
    ├── tests/
    └── ...
```

## Shared Context

Lint rules use a shared context defined in `sample_project/spec/spec_helper.rb` that provides pre-built collections:

```ruby
let(:controllers) { project.files.with_paths('src/controllers/').classes }
let(:models) { project.files.with_paths('src/models/').classes }
let(:services) { project.files.with_paths('src/services/').classes }
```

## Environment Setup

Lint rules require `RUBYZEN_PROJECT_PATHS` to point at the source to analyze:

```bash
# Required: comma-separated absolute paths
export RUBYZEN_PROJECT_PATHS="/path/to/src,/path/to/spec"

# Legacy: single directory (still supported)
export RUBYZEN_PROJECT_PATH="/path/to/src"

# Dev container: specify which sibling project to mount
export RUBYZEN_TARGET_PROJECT="my-project"
```
