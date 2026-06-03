# Changelog

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
