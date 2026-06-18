# Changelog

## [0.3.0]

### Added

- **`ExpressionDeclaration`** — a value-expression primitive wrapping any AST node, with
  predicates (`constant?`, `local_variable?`, `method_call?`, `constructor?`, `hash_literal?`,
  `symbol?`, `string?`) and accessors (`constant_name`, `method_name`, `name`). Surfaced through
  new providers so rules can inspect values without dropping to the raw AST.
- **`#return_expressions`** on `MethodDeclaration` and `BlockDeclaration` — the value-expression(s)
  it evaluates to (implicit final expression + explicit `return`s), as an `ExpressionsCollection`
  (`#hash_literals`, `#constants`). Bridged on `MethodsCollection` and `BlocksCollection`.
- **`CallSiteDeclaration#arguments`** — the call's arguments as an `ExpressionsCollection`.
- **`CallSiteDeclaration#receiver_expression`** — the receiver modeled structurally (constant /
  constructor / local variable). `#receiver` (String const-name) is unchanged.
- **`CallSiteDeclaration#enclosing_blocks`** — the chain of enclosing `do..end`/`{ }` blocks
  (innermost first), as a `BlocksCollection`.
- **`#assignments`** on `MethodDeclaration` and `BlockDeclaration` — local-variable assignments
  (`AssignmentDeclaration`, with `#name` and `#value`) as an `AssignmentsCollection`. Bridged on
  `MethodsCollection` and `BlocksCollection`.

All additions are backward-compatible; no existing API changed.

## [0.2.0]

### Added

- **Minitest adapter.** Write architectural lint rules with Minitest using
  `require 'rubyzen/minitest'`. This provides the `assert_zen_empty`, `assert_zen_true`,
  and `assert_zen_false` assertions, which mirror the RSpec matchers.

### Changed

- **`rspec` is no longer a runtime dependency.** Rubyzen no longer depends 
  on RSpec at runtime; RSpec users should add `gem 'rspec'` (or `rspec-rails`)
  to their Gemfile. This allows Minitest users to not depend on RSpec.

### Migration from 0.1.x

- Change `require 'rubyzen'` to `require 'rubyzen/rspec'`.
- Ensure `gem 'rspec'` is in your Gemfile's test group.

## [0.1.0]

- Initial release
