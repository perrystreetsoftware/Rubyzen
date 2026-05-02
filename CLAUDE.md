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

## Environment Setup

```bash
# Required: comma-separated absolute paths to analyze
export RUBYZEN_PROJECT_PATHS="/path/to/src,/path/to/spec"

# Legacy: single directory (still supported)
export RUBYZEN_PROJECT_PATH="/path/to/src"

# Dev container: specify which sibling project to mount
export RUBYZEN_TARGET_PROJECT="my-project"
```

## GitHub Action Integration

Rubyzen ships with a GitHub Action (`action.yml`) for running lint analysis in CI/CD:
- Configurable target directory and RSpec directory
- Outputs violations found and full analysis results

## Skills

The following skills are available in `.claude/skills/` to guide AI agents:

| Skill | Purpose |
|---|---|
| `run-tests` | Run Rubyzen's unit test suite |
| `run-lint-rules` | Run sample project lint rules and verify violation detection |
| `write-lint-rule` | Write an architectural lint rule using the Rubyzen API |
| `add-rubyzen-tests` | Write unit tests for Rubyzen's own components |
| `expand-rubyzen` | Add a new Rubyzen API (Declaration + Provider + Collection) |
