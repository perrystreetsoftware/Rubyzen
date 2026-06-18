# Rubyzen Architecture Guide

## What is Rubyzen

Rubyzen is a Ruby architectural linter that lets you write lint rules as RSpec or Minitest tests. Inspired by Konsist (Kotlin) and Harmonize (Swift), it wraps RuboCop AST to provide a high-level, easy-to-use API for enforcing architectural rules across a codebase.

Instead of configuring YAML rules, you write standard unit tests.

Using RSpec (`require 'rubyzen/rspec'`):

```ruby
it 'controllers do not call ActiveRecord directly' do
  expect(controllers.all_methods.call_sites.with_name('where')).to zen_empty
end
```

Or using Minitest (`require 'rubyzen/minitest'`):

```ruby
def test_controllers_do_not_call_active_record_directly
  assert_zen_empty(controllers.all_methods.call_sites.with_name('where'))
end
```

## Core Concepts

Rubyzen has four main building blocks:

| Concept | Purpose | Example |
|---|---|---|
| **Declarations** | Domain objects wrapping AST nodes | `ClassDeclaration`, `MethodDeclaration`, `CallSiteDeclaration` |
| **Collections** | Typed arrays of declarations with filtering/aggregation | `ClassesCollection`, `MethodsCollection` |
| **Providers** | Mixins that add capabilities to declarations | `CallSiteProvider`, `BlocksProvider` |
| **Matchers / Assertions** | RSpec matchers and Minitest assertions for asserting on collections | `zen_empty` / `assert_zen_empty`, `zen_true { }` / `assert_zen_true { }`, `zen_false { }` / `assert_zen_false { }` |

## Data Flow

```
Project
  └── files → FileCollection
        ├── .classes → ClassesCollection
        │     ├── .all_methods → MethodsCollection
        │     │     ├── .parameters → ParametersCollection
        │     │     ├── .call_sites → CallSiteCollection
        │     │     │     └── (each) .arguments → ExpressionsCollection
        │     │     │         .receiver_expression → ExpressionDeclaration
        │     │     │         .enclosing_blocks → BlocksCollection
        │     │     ├── .return_expressions → ExpressionsCollection
        │     │     ├── .assignments → AssignmentsCollection
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
        │     ├── .call_sites → CallSiteCollection
        │     ├── .return_expressions → ExpressionsCollection
        │     └── .assignments → AssignmentsCollection
        ├── .constants → ConstantsCollection
        └── .requires → RequiresCollection
```

Every arrow is a method that returns a typed collection. Collections support chaining via filtering methods.

## Folder Structure

```
lib/rubyzen/
├── rubyzen.rb                    # Entry point — loads core only (require 'rubyzen')
├── core.rb                       # Framework-agnostic core: Zeitwerk loader + Rubyzen module/Configuration
├── rspec.rb                      # RSpec adapter (require 'rubyzen/rspec'): core + matchers
├── minitest.rb                   # Minitest adapter (require 'rubyzen/minitest'): core + assertions
├── expectation_helpers.rb        # Rubyzen::ExpectationHelpers — shared engine for matchers + assertions
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
├── matchers/                     # RSpec matchers (loaded by rubyzen/rspec)
│   ├── zen_empty_matcher.rb
│   ├── zen_true_matcher.rb
│   └── zen_false_matcher.rb
├── assertions/                   # Minitest assertions (loaded by rubyzen/minitest)
│   ├── zen_assertions.rb
│   ├── assert_zen_empty.rb
│   ├── assert_zen_true.rb
│   └── assert_zen_false.rb
├── parsers/
│   └── a_s_t_parser.rb          # Wraps RuboCop AST ProcessedSource
├── cache/
│   └── parse_cache.rb           # SHA256-based in-memory parse cache
└── version.rb                    # Gem version constant

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
│   ├── spec_helper.rb            # Shared context with common collections (require 'rubyzen/rspec')
│   ├── controllers/
│   ├── models/
│   ├── presenters/
│   ├── tests/
│   └── ...
└── test/                         # Lint rules as Minitest tests (parallel subset)
    ├── test_helper.rb            # LintTestCase base class (require 'rubyzen/minitest')
    ├── controllers/
    ├── models/
    ├── repos/
    └── database/
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
| `MethodDeclaration` | `name`, `parameters`, `parameters?`, `return_expressions`, `assignments` | FilePathProvider, ClassNameProvider, LinesOfCodeProvider, CallSiteProvider, BlocksProvider, IfStatementsProvider, ConstantsProvider, VisibilityProvider, RescuesProvider, RaisesProvider, ReturnExpressionsProvider, AssignmentsProvider |
| `CallSiteDeclaration` | `name`, `receiver`, `receiver_expression`, `method_name`, `arguments`, `enclosing_blocks`, `keyword_args`, `keyword_arg_value_pairs`, `symbols`, `strings` | FilePathProvider, LineNumberProvider, ClassNameProvider, SourceCodeProvider, ArgumentsProvider, EnclosingBlocksProvider |
| `ExpressionDeclaration` | `name`, `constant?`, `local_variable?`, `method_call?`, `constructor?`, `hash_literal?`, `symbol?`, `string?`, `constant_name`, `method_name` | FilePathProvider, LineNumberProvider, ClassNameProvider, SourceCodeProvider |
| `AssignmentDeclaration` | `name`, `value` | FilePathProvider, LineNumberProvider, ClassNameProvider, SourceCodeProvider |
| `BlockDeclaration` | `name`, `method_name`, `return_expressions`, `assignments` | FilePathProvider, LineNumberProvider, ClassNameProvider, LinesOfCodeProvider, SourceCodeProvider, CallSiteProvider, RescuesProvider, RaisesProvider, ReturnExpressionsProvider, AssignmentsProvider |
| `ParameterDeclaration` | `name`, `default_value` | FilePathProvider, LineNumberProvider, ClassNameProvider |
| `ConstantDeclaration` | `name`, `value`, `assignment?`, `reference?`, `top_level?` | FilePathProvider, LineNumberProvider, ClassNameProvider, SourceCodeProvider |
| `AttributeDeclaration` | `name`, `symbols`, `reader?`, `writer?`, `accessor?` | FilePathProvider, ClassNameProvider, LineNumberProvider, VisibilityProvider |
| `MacroDeclaration` | `name`, `symbols`, `strings`, `keyword_args`, `receiver` | FilePathProvider, ClassNameProvider, LineNumberProvider, SourceCodeProvider |
| `RequireDeclaration` | `name`, `required_path`, `require?`, `require_relative?` | FilePathProvider, LineNumberProvider |
| `IfStatementDeclaration` | `name`, `condition_source` | FilePathProvider, ClassNameProvider, LineNumberProvider, SourceCodeProvider |
| `RaiseDeclaration` | `exception_types`, `with_string?`, `message` | FilePathProvider, LineNumberProvider, ClassNameProvider, SourceCodeProvider |
| `RescueDeclaration` | `exception_types` | FilePathProvider, LineNumberProvider, ClassNameProvider |

## Matchers (RSpec) and Assertions (Minitest)

Rubyzen exposes the same three checks for both frameworks. The RSpec matchers (`lib/rubyzen/matchers/`) and the Minitest assertions (`lib/rubyzen/assertions/`) both delegate to the shared `Rubyzen::ExpectationHelpers` (`lib/rubyzen/expectation_helpers.rb`) for allowlist/baseline classification and for formatting failure messages with element name, class, and file location.

| RSpec matcher | Minitest assertion | Purpose |
|---|---|---|
| `zen_empty` | `assert_zen_empty(collection)` | Collection has no elements. Supports `allowlist:` / `baseline:` for gradual adoption. |
| `zen_true { \|item\| }` | `assert_zen_true(collection) { \|item\| }` | Block returns true for ALL elements. Supports `allowlist:` / `baseline:`. |
| `zen_false { \|item\| }` | `assert_zen_false(collection) { \|item\| }` | Block returns false for ALL elements. Supports `allowlist:` / `baseline:`. |

### Examples

RSpec:

```ruby
expect(violations).to zen_empty(baseline: [...])
expect(methods).to zen_true { |m| m.parameters.any? }
expect(methods).to zen_false { |m| m.name == :biz }
```

Minitest:

```ruby
assert_zen_empty(violations, baseline: [...])
assert_zen_true(methods) { |m| m.parameters.any? }
assert_zen_false(methods) { |m| m.name == :biz }
```

**Important (RSpec only):** Use `{ }` braces (not `do...end`) with `zen_true`/`zen_false` — `do...end` binds to `expect()` instead of the matcher due to Ruby precedence. This caveat does not apply to the Minitest assertions (the block binds to the assertion method either way).

## Configuration

Rubyzen resolves project paths in this order:

1. **Explicit paths:** `Rubyzen::Project.new(['app', 'lib'])`
2. **DSL config:** `Rubyzen.configure { |c| c.paths = ['app', 'lib'] }`
3. **Auto-discovery:** Scans `app/`, `lib/`, `src/`, `spec/` from `Dir.pwd`

Relative paths are resolved against `Dir.pwd`.

## Skills

The following skills are available in `.claude/skills/` to guide AI agents:

| Skill | Purpose |
|---|---|
| `run-tests` | Run Rubyzen's unit test suite |
| `run-lint-rules` | Run sample project lint rules and verify violation detection |
| `write-lint-rule` | Write an architectural lint rule using the Rubyzen API |
| `add-rubyzen-tests` | Write unit tests for Rubyzen's own components |
| `expand-rubyzen` | Add a new Rubyzen API (Declaration + Provider + Collection) |
