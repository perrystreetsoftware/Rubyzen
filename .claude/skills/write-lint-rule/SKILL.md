---
name: write-lint-rule
description: Write an architectural lint rule for a Ruby project using the Rubyzen API. Use this skill when the user wants to create a new lint rule, enforce an architectural constraint, add a code quality check, or write an RSpec test that validates code structure. Also trigger when the user says things like "controllers shouldn't do X", "models must always Y", "enforce that Z", or "add a rule for".
---

# Writing a Lint Rule with Rubyzen

You are writing an architectural lint rule as an RSpec test using Rubyzen's high-level API. Lint rules enforce structural constraints on a Ruby codebase without touching raw AST.

## Step 0: Understand the Available API

Read `CLAUDE.md` to understand the full API surface. Pay special attention to:
- The **Data Flow** tree (what collections are available and how they chain)
- The **Declaration Reference** table (what methods each declaration exposes)
- The **Matchers** section (what assertions are available)

Also read `sample_project/spec/spec_helper.rb` to see how collections are set up.

## Step 1: Translate the Rule to API Calls

Every lint rule follows this mental model:

```
SCOPE → FILTER → EXTRACT → ASSERT
```

1. **SCOPE**: Start from `project.files` and narrow to the right files
2. **FILTER**: Chain collection methods to isolate the code you care about
3. **EXTRACT**: Get the specific declarations to check
4. **ASSERT**: Use a matcher to enforce the constraint

**Examples of translating English rules to API calls:**

| English Rule | Rubyzen API |
|---|---|
| "Controllers must not call `.where`" | `controllers.all_methods.call_sites.with_name('where')` → `be_empty` |
| "Models must not define methods ending with `?`" | `models.all_methods.with_name_ending_with('?')` → `be_empty` |
| "All service classes must inherit from BaseService" | `services` → `be_true { \|k\| k.superclass_name == 'BaseService' }` |
| "Presenters must not use repository classes" | `presenters.all_methods.call_sites.with_receiver('UserRepo')` → `be_empty` |
| "No class should have more than 200 lines" | `all_classes` → `be_true { \|k\| k.lines_of_code <= 200 }` |
| "Every public method must have at most 3 parameters" | `methods.filter(&:public?)` → `be_true { \|m\| m.parameters.size <= 3 }` |

## Step 2: Set Up the Shared Context

Lint rules use a shared context in `spec_helper.rb` that provides pre-built collections. Read the existing `spec_helper.rb` in the target project's spec directory. If it doesn't exist, create one:

```ruby
require 'rubyzen'

RSpec.configure do |config|
  RSpec.shared_context 'project_config' do
    let(:project) { Rubyzen::Project.new }
    let(:files) { project.files.with_paths('src/') }

    # Scope collections by directory
    let(:controllers) { project.files.with_paths('src/controllers/').classes }
    let(:models) { project.files.with_paths('src/models/').classes }
    let(:services) { project.files.with_paths('src/services/').classes }
    let(:repos) { project.files.with_paths('src/repos/').without_paths('/spec/').classes }
    let(:test_files) { project.files.with_paths('spec/') }
    # Add more as needed...
  end

  # Auto-include in all specs so you don't need include_context in every file
  config.include_context 'project_config'
end
```

## Step 3: Write the Lint Rule

Create a spec file in the appropriate directory. If the shared context is auto-included via `config.include_context`, you don't need to include it manually:

```ruby
require_relative '../spec_helper'

RSpec.describe 'Rule: Controllers must not call ActiveRecord directly' do
  # `controllers`, `models`, etc. are available from the shared context

  it 'controllers do not use .where' do
    violations = controllers
      .all_methods
      .call_sites
      .with_name('where')

    expect(violations).to be_empty
  end

  it 'controllers do not use .find_by' do
    violations = controllers
      .all_methods
      .call_sites
      .with_name('find_by')

    expect(violations).to be_empty
  end
end
```

## Available Matchers

### `be_empty`
Asserts the collection has no elements. Use for "must not" / "should never" rules. Supports `allowlist:` and `baseline:` for gradual adoption.

```ruby
expect(violations).to be_empty
expect(violations).to be_empty("Custom failure message explaining the rule")

# Allowlist: permanently accepted exceptions
expect(violations).to be_empty(allowlist: ['LegacyController'])

# Baseline: existing violations to fix over time (stale entries cause failure)
expect(violations).to be_empty(baseline: ['OldController', 'AncientController'])
```

Entries match against `name`, `class_name`, `file_path`, or `file_path:line`. Stale entries (listed but no longer violating) cause test failure — this prevents the baseline from going stale.

### `be_true { |item| ... }`
Asserts the block returns `true` for ALL elements. Use for "must always" / "every X should" rules. Supports `allowlist:` and `baseline:` for items that fail the check.

```ruby
expect(services).to be_true { |klass| klass.superclass_name == 'BaseService' }

# With baseline for gradual adoption
expect(services).to be_true(baseline: ['LegacyService']) { |klass| klass.superclass_name == 'BaseService' }
```

**IMPORTANT:** Use `{ }` braces, NOT `do...end`. Due to Ruby operator precedence, `do...end` binds to `expect()` instead of the matcher, causing a silent bug.

### `be_false { |item| ... }`
Asserts the block returns `false` for ALL elements. Inverse of `be_true`. Supports `allowlist:` and `baseline:` for items that fail the check.

```ruby
expect(models).to be_false { |m| m.name.end_with?('Helper') }

# With baseline for gradual adoption
expect(models).to be_false(baseline: ['OldHelper']) { |m| m.name.end_with?('Helper') }
```

### `be_empty_with_exceptions` (deprecated)
**Deprecated.** Use `be_empty(allowlist:, baseline:)` instead — it now supports all the same capabilities.

```ruby
# Before (deprecated):
expect(violations).to be_empty_with_exceptions(allowlist: ['LegacyController'])

# After (preferred):
expect(violations).to be_empty(allowlist: ['LegacyController'])
```

## Common API Patterns

### Filtering by file path
```ruby
files.with_paths('app/controllers/')      # files whose path includes this string
files.without_paths('/spec/', '/test/')    # exclude test files
```

### Filtering by name
```ruby
classes.with_name('UsersController')
classes.with_name_ending_with('Controller')
classes.with_name_starting_with('Admin')
classes.with_name_including('Service')
classes.without_name('BaseController')
```

### Traversing the hierarchy
```ruby
classes.all_methods                        # MethodsCollection (instance + class methods)
classes.all_methods.call_sites             # CallSiteCollection across all methods
classes.all_methods.parameters             # ParametersCollection
classes.attributes                         # AttributesCollection
classes.macros                             # MacrosCollection
classes.macros.with_name('belongs_to')     # filter macros by name
```

### Call site analysis
```ruby
call_sites.with_receiver('User')           # calls on specific receiver
call_sites.with_name('where')              # calls to specific method
call_sites.with_symbol(:admin)             # calls with specific symbol arg
call_sites.with_keyword_arg(:foreign_key)  # calls with specific keyword arg
```

### Method properties
```ruby
methods.filter(&:private?)                 # private methods
methods.filter(&:public?)                  # public methods
method.lines_of_code                       # number of lines
method.parameters                          # ParametersCollection
method.call_sites                          # CallSiteCollection
method.if_statements                       # DeclarationCollection
method.rescues                             # RescuesCollection
method.raises                              # RaisesCollection
```

### Class properties
```ruby
klass.superclass_name                      # parent class name
klass.superclass_prefix?('Base')           # inheritance check
klass.top_level_module                     # e.g., "Admin" for Admin::UsersController
klass.instance_methods                     # only instance methods
klass.class_methods                        # only class methods
```

### Combining collections
```ruby
# Use + to merge collections of the same type
(jobs + services).all_methods.call_sites   # call sites across both
(controllers + presenters).all_methods     # methods from both layers
```

### Custom filtering with `filter`
For complex rules that can't be expressed with built-in filters, use `filter` with a block:

```ruby
# Find calls to deliver that have request_guid but not remote_addr
deliver_calls = call_sites
  .with_receiver('Relay')
  .with_method_name('deliver')

violations = deliver_calls.filter do |site|
  site.keyword_args.include?(:request_guid) &&
    !site.keyword_args.include?(:remote_addr)
end

expect(violations).to be_empty
```

### Block analysis
```ruby
file.blocks                                # top-level blocks
file.blocks.with_method_name('describe')   # RSpec describe blocks
block.call_sites                           # calls within the block
```

## Failure Messages

Rubyzen matchers automatically format failure messages with:
- Element name (method name, class name, etc.)
- Class name (parent class)
- File path and line number

This makes violations immediately actionable — developers see exactly where the violation is.

## Checklist

- [ ] Rule file is in the correct spec directory
- [ ] Shared context is available (auto-included or via `include_context 'project_config'`)
- [ ] Uses `be_empty` for "must not" rules, `be_true { }` for "must always" rules
- [ ] Uses `{ }` braces (not `do...end`) with `be_true`/`be_false`
- [ ] Custom failure message explains *why* the rule exists (optional but recommended)
- [ ] `bundle exec rspec path/to/spec` runs successfully
