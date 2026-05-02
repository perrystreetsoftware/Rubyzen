# Rubyzen Architecture Guide

## What is Rubyzen

Rubyzen is a Ruby architectural linter that lets you write lint rules as RSpec tests. Inspired by Konsist (Kotlin) and Harmonize (Swift), it wraps RuboCop AST to provide a high-level, easy-to-use API for enforcing architectural rules across a codebase.

Instead of configuring YAML rules, you write standard RSpec tests:

```ruby
it 'controllers do not call ActiveRecord directly' do
  expect(controllers.all_methods.call_sites.with_name('where')).to be_empty
end
```

## Core Concepts

Rubyzen has four main building blocks:

| Concept | Purpose | Example |
|---|---|---|
| **Declarations** | Domain objects wrapping AST nodes | `ClassDeclaration`, `MethodDeclaration`, `CallSiteDeclaration` |
| **Collections** | Typed arrays of declarations with filtering/aggregation | `ClassesCollection`, `MethodsCollection` |
| **Providers** | Mixins that add capabilities to declarations | `CallSiteProvider`, `BlocksProvider` |
| **Matchers** | RSpec matchers for asserting on collections | `be_empty`, `be_true { }`, `be_false { }` |

## Data Flow

```
Project
  └── files → FileCollection
        ├── .classes → ClassesCollection
        │     ├── .all_methods → MethodsCollection
        │     │     ├── .parameters → ParametersCollection
        │     │     ├── .call_sites → CallSiteCollection
        │     │     ├── .if_statements → DeclarationCollection
        │     │     ├── .rescues → RescuesCollection
        │     │     └── .raises → RaisesCollection
        │     ├── .attributes → AttributesCollection
        │     ├── .macros → MacrosCollection
        │     ├── .rescues → RescuesCollection
        │     └── .raises → RaisesCollection
        ├── .modules → ModulesCollection
        ├── .call_sites → CallSiteCollection
        ├── .blocks → BlocksCollection
        │     └── .call_sites → CallSiteCollection
        ├── .constants → ConstantsCollection
        └── .requires → RequiresCollection
```

Every arrow is a method that returns a typed collection. Collections support chaining via filtering methods.

## Folder Structure

```
lib/rubyzen/
├── rubyzen.rb                    # Entry point, Zeitwerk loader, configuration
├── project.rb                    # Parses all .rb files, returns FileCollection
├── declarations/                 # Domain objects wrapping AST nodes
│   ├── file_declaration.rb
│   ├── class_declaration.rb
│   ├── module_declaration.rb
│   ├── method_declaration.rb
│   ├── parameter_declaration.rb
│   ├── call_site_declaration.rb
│   ├── block_declaration.rb
│   ├── constant_declaration.rb
│   ├── require_declaration.rb
│   ├── attribute_declaration.rb
│   ├── if_statement_declaration.rb
│   ├── macro_declaration.rb
│   ├── raise_declaration.rb
│   └── rescue_declaration.rb
├── collections/                  # Typed arrays with filtering/aggregation
│   ├── base_collection.rb        # Extends Array, provides filter method
│   ├── file_collection.rb
│   ├── classes_collection.rb
│   ├── modules_collection.rb
│   ├── methods_collection.rb
│   ├── parameters_collection.rb
│   ├── call_site_collection.rb
│   ├── blocks_collection.rb
│   ├── constants_collection.rb
│   ├── requires_collection.rb
│   ├── attributes_collection.rb
│   ├── macros_collection.rb
│   ├── raises_collection.rb
│   ├── rescues_collection.rb
│   └── declaration_collection.rb
├── providers/                    # Mixins included in declarations
│   ├── file_path_provider.rb
│   ├── line_number_provider.rb
│   ├── lines_of_code_provider.rb
│   ├── class_name_provider.rb
│   ├── source_code_provider.rb
│   ├── call_site_provider.rb
│   ├── blocks_provider.rb
│   ├── if_statements_provider.rb
│   ├── constants_provider.rb
│   ├── requires_provider.rb
│   ├── attributes_provider.rb
│   ├── macros_provider.rb
│   ├── raises_provider.rb
│   ├── rescues_provider.rb
│   ├── visibility_provider.rb
│   └── collection_filter_provider.rb
├── matchers/                     # RSpec custom matchers
│   ├── matcher_helpers.rb
│   ├── be_empty_matcher.rb
│   ├── be_empty_with_exceptions_matcher.rb
│   ├── be_true_matcher.rb
│   └── be_false_matcher.rb
├── parsers/
│   └── a_s_t_parser.rb          # Wraps RuboCop AST ProcessedSource
├── cache/
│   └── parse_cache.rb           # SHA256-based in-memory parse cache
└── rspec/
    └── rspec_config.rb           # Validates expect() subjects are collections

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
    ├── spec_helper.rb            # Shared context with common collections
    ├── controllers/
    ├── models/
    ├── presenters/
    ├── tests/
    └── ...
```

## How the Pieces Connect

### Declarations include Providers

Each declaration includes providers as mixins to gain capabilities. The `node` and `parent` attributes are used by providers to traverse the AST.

```ruby
class MethodDeclaration
  include Rubyzen::Providers::CallSiteProvider    # adds .call_sites
  include Rubyzen::Providers::BlocksProvider      # adds .blocks
  include Rubyzen::Providers::IfStatementsProvider # adds .if_statements
  # ...
end
```

### Providers return Collections

Providers create typed collections from AST node descendants:

```ruby
module CallSiteProvider
  def call_sites
    Collections::CallSiteCollection.new(
      node.each_descendant(:send).map { |n| Declarations::CallSiteDeclaration.new(n, self) }
    )
  end
end
```

### Collections bridge to other Collections

Collections aggregate their elements' sub-collections via bridge methods:

```ruby
class MethodsCollection < BaseCollection
  def call_sites
    CallSiteCollection.new(flat_map(&:call_sites))
  end
end
```

### BaseCollection

All collections extend `BaseCollection`, which extends `Array` with:
- `filter` method that returns the same collection type (critical for chaining)
- Removes `select` and `reject` to enforce using `filter`

### CollectionFilterProvider

All collections include `CollectionFilterProvider`, which adds name-based filtering:
- `with_name`, `without_name`
- `with_name_starting_with`, `with_name_ending_with`, `with_name_including`
- And their `without_` counterparts

Some collections add domain-specific filters (e.g., `CallSiteCollection.with_symbol`, `FileCollection.with_paths`).

## Declaration Reference

Each declaration wraps an AST node and exposes domain-specific methods:

| Declaration | Key Methods | Providers |
|---|---|---|
| `FileDeclaration` | `name`, `classes`, `modules` | FilePathProvider, LinesOfCodeProvider, ConstantsProvider, RequiresProvider, CallSiteProvider, BlocksProvider |
| `ClassDeclaration` | `name`, `superclass_name`, `instance_methods`, `class_methods`, `top_level_module` | FilePathProvider, ClassNameProvider, LinesOfCodeProvider, ConstantsProvider, AttributesProvider, MacrosProvider, BlocksProvider, IfStatementsProvider, RescuesProvider, RaisesProvider |
| `MethodDeclaration` | `name`, `parameters`, `parameters?` | FilePathProvider, ClassNameProvider, LinesOfCodeProvider, CallSiteProvider, BlocksProvider, IfStatementsProvider, ConstantsProvider, VisibilityProvider, RescuesProvider, RaisesProvider |
| `CallSiteDeclaration` | `name`, `receiver`, `method_name`, `keyword_args`, `keyword_arg_value_pairs`, `symbols`, `strings` | FilePathProvider, LineNumberProvider, ClassNameProvider, SourceCodeProvider |
| `BlockDeclaration` | `name`, `method_name` | FilePathProvider, LineNumberProvider, ClassNameProvider, LinesOfCodeProvider, SourceCodeProvider, CallSiteProvider, RescuesProvider, RaisesProvider |
| `ParameterDeclaration` | `name`, `default_value` | FilePathProvider, LineNumberProvider, ClassNameProvider |
| `ConstantDeclaration` | `name`, `value`, `assignment?`, `reference?`, `top_level?` | FilePathProvider, LineNumberProvider, ClassNameProvider, SourceCodeProvider |
| `AttributeDeclaration` | `name`, `symbols`, `reader?`, `writer?`, `accessor?` | FilePathProvider, ClassNameProvider, LineNumberProvider, VisibilityProvider |
| `MacroDeclaration` | `name`, `symbols`, `strings`, `keyword_args`, `receiver` | FilePathProvider, ClassNameProvider, LineNumberProvider, SourceCodeProvider |
| `RequireDeclaration` | `name`, `required_path`, `require?`, `require_relative?` | FilePathProvider, LineNumberProvider |
| `IfStatementDeclaration` | `name`, `condition_source` | FilePathProvider, ClassNameProvider, LineNumberProvider, SourceCodeProvider |
| `RaiseDeclaration` | `exception_types`, `with_string?`, `message` | FilePathProvider, LineNumberProvider, ClassNameProvider, SourceCodeProvider |
| `RescueDeclaration` | `exception_types` | FilePathProvider, LineNumberProvider, ClassNameProvider |

## Matchers

All matchers use `MatcherHelpers` for formatting failure messages with element name, class, and file location.

| Matcher | Purpose | Usage |
|---|---|---|
| `be_empty` | Collection has no elements. Supports `allowlist:` and `baseline:` for gradual adoption. | `expect(violations).to be_empty` or `expect(violations).to be_empty(baseline: [...])` |
| `be_true { \|item\| }` | Block returns true for ALL elements. Supports `allowlist:` and `baseline:`. | `expect(methods).to be_true { \|m\| m.parameters.any? }` |
| `be_false { \|item\| }` | Block returns false for ALL elements. Supports `allowlist:` and `baseline:`. | `expect(methods).to be_false { \|m\| m.name == :biz }` |
| `be_empty_with_exceptions` | **Deprecated.** Use `be_empty(allowlist:, baseline:)` instead. | `expect(items).to be_empty_with_exceptions(baseline: [...])` |

**Important:** Use `{ }` braces (not `do...end`) with `be_true`/`be_false` — `do...end` binds to `expect()` instead of the matcher due to Ruby precedence.

## Patterns for Expanding the Project

### Adding a new Declaration

1. Create `lib/rubyzen/declarations/foo_declaration.rb`
2. Include relevant providers (`FilePathProvider`, `LineNumberProvider`, `ClassNameProvider` at minimum for matcher output)
3. Add `attr_reader :node, :parent` and standard `initialize(node, parent)`
4. Add a `name` method (used by matchers for failure messages)

### Adding a new Collection

1. Create `lib/rubyzen/collections/foos_collection.rb`
2. Extend `BaseCollection`, include `CollectionFilterProvider`
3. Add domain-specific filter methods as needed

### Adding a new Provider

1. Create `lib/rubyzen/providers/foos_provider.rb`
2. Define a module with a method that finds AST nodes and returns a typed collection
3. Include the provider in relevant declarations

### Connecting it all

1. Include the provider in declarations that should expose the new data
2. Add bridge methods to collections that should aggregate the data (e.g., `MethodsCollection#foos`)
3. Zeitwerk handles autoloading — no manual requires needed

### Adding a sample lint rule

1. Add violating source code in `sample_project/src/`
2. Add lint spec in `sample_project/spec/`
3. Use the shared context `project_config` from `spec_helper.rb`
4. The test should **fail** (sample project intentionally contains violations)

## Testing

Rubyzen has two separate test suites that serve different purposes:

### Unit Tests (`spec/`)

Unit tests verify the correctness of Rubyzen's own API — declarations, providers, collections, and matchers. They live in `spec/` at the project root.

```bash
# Run all unit tests
bundle exec rspec spec/

# Run a specific declaration test
bundle exec rspec spec/declarations/class_declaration_spec.rb
```

**Structure:**

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

**The `parse_ruby` helper:**

Most unit tests parse inline Ruby snippets using the `parse_ruby` helper defined in `spec/support/parse_helper.rb`:

```ruby
def parse_ruby(source, file_path: 'test.rb')
  processed = RuboCop::AST::ProcessedSource.new(source, RUBY_VERSION.to_f, file_path)
  Rubyzen::Declarations::FileDeclaration.new(file_path, processed.ast)
end
```

This bypasses file I/O and lets each test define exactly the Ruby code it needs:

```ruby
it 'returns the class name' do
  file = parse_ruby(<<~RUBY)
    class UserController < ApplicationController
      def index; end
    end
  RUBY

  klass = file.classes.first
  expect(klass.name).to eq('UserController')
end
```

**When to use fixture files instead:** Tests that need to verify file-scoping behavior (`Project.new`, `FileCollection#with_paths`, `FileCollection#without_paths`) use actual `.rb` files in `spec/fixtures/` since those features depend on real file paths.

**Single-statement gotcha:** When a Ruby snippet contains only one statement, the AST root node IS that statement (not a `:begin` wrapper). This means `each_descendant` won't find it. Always include at least two statements in snippets that test providers using `each_descendant` (e.g., constants, requires, blocks at file level):

```ruby
# Bad — single statement, root is :casgn, each_descendant won't find it
file = parse_ruby('MAX = 100')
file.constants  # => empty!

# Good — two statements, root is :begin, each_descendant works
file = parse_ruby("MAX = 100\nx = 1")
file.constants  # => [ConstantDeclaration(MAX)]
```

### Sample Project Lint Rules (`sample_project/spec/`)

Lint rule specs verify that Rubyzen can enforce architectural rules on a real codebase. They use the `project_config` shared context from `sample_project/spec/spec_helper.rb`, which provides pre-built collection helpers (`controllers`, `models`, `repos`, etc.).

```bash
# Run all lint rules on the sample project
bundle exec rspec sample_project/spec/

# Run a specific lint rule
bundle exec rspec sample_project/spec/controllers/no_if_statements_in_controllers_lint_spec.rb
```

The sample project intentionally contains violations, so lint rule tests are expected to **fail** — they validate that Rubyzen correctly detects violations.

## Environment Setup

```bash
# Required: comma-separated absolute paths to analyze
export RUBYZEN_PROJECT_PATHS="/path/to/src,/path/to/spec"

# Legacy: single directory (still supported)
export RUBYZEN_PROJECT_PATH="/path/to/src"

# Dev container: specify which sibling project to mount
export RUBYZEN_TARGET_PROJECT="my-project"

# Run unit tests
bundle exec rspec spec/

# Run lint rules on sample project
bundle exec rspec sample_project/spec/

# Run a specific rule
bundle exec rspec sample_project/spec/controllers/no_if_statements_in_controllers_lint_spec.rb
```

## GitHub Action Integration

Rubyzen ships with a GitHub Action (`action.yml`) for running lint analysis in CI/CD:
- Configurable target directory and RSpec directory
- Outputs violations found and full analysis results

## Dependencies

- `rubocop-ast` — AST parsing engine (wraps Parser gem)
- `rspec` — Test framework for writing lint rules
- `zeitwerk` — Autoloading (no manual requires needed for new files)
