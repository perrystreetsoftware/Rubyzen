# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

### Testing and Analysis
```bash
# Run Rubyzen lint rules on the sample project
bundle exec rspec sample_project/spec/

# Run Rubyzen lint rules on a target project
bundle exec rspec target_project/spec/rubyzen/

# Run specific lint rule
bundle exec rspec sample_project/spec/controllers/controllers_must_have_tests_lint_spec.rb
```

### Environment Setup
- Set `RUBYZEN_PROJECT_PATHS` environment variable to colon-separated absolute paths of directories to analyze (e.g., "/path/to/src:/path/to/spec")
- Alternatively, set `RUBYZEN_PROJECT_PATH` for single directory (legacy support)
- For dev container usage, set `RUBYZEN_TARGET_PROJECT` to specify which sibling project to mount

## Architecture

Rubyzen is a Ruby architectural linter that allows writing lint rules as unit tests, inspired by Konsist (Kotlin) and Harmonize (Swift). It uses RuboCop AST under the hood but provides a high-level API for architectural rule enforcement.

### Core Components

**Main Entry Point:**
- `lib/rubyzen.rb` - Main module with configuration system that requires `RUBYZEN_PROJECT_PATH` environment variable

**Project Analysis:**
- `lib/rubyzen/project.rb` - Main project analyzer that parses Ruby files and provides access to files and classes

**Collections (High-level API):**
- `lib/rubyzen/collections/base_collection.rb` - Base collection functionality
- `lib/rubyzen/collections/file_collection.rb` - File-based operations and filtering
- `lib/rubyzen/collections/classes_collection.rb` - Class-based operations
- `lib/rubyzen/collections/methods_collection.rb` - Method-based operations
- `lib/rubyzen/collections/call_site_collection.rb` - Call site analysis
- `lib/rubyzen/collections/declaration_collection.rb` - Declaration handling

**AST Parsing:**
- `lib/rubyzen/parsers/ast_parser.rb` - Wraps RuboCop AST for parsing Ruby code

**Code Declarations:**
- `lib/rubyzen/declarations/` - Represents different code structures (classes, methods, files, blocks, if statements, call sites)

**Providers:**
- `lib/rubyzen/providers/` - Extract specific information from AST (blocks, call sites, class names, constants, file paths, if statements, line numbers, lines of code)

**Matchers:**
- `lib/rubyzen/matchers/` - Custom matchers for architectural rules (be_empty, be_true, be_false)

**Caching:**
- `lib/rubyzen/cache/parse_cache.rb` - Caches parsed AST for performance

### Sample Project Structure
- `sample_project/src/` - Sample Ruby application with different architectural layers (controllers, models, presenters, repos, actions)
- `sample_project/spec/` - Lint rules written as RSpec tests, organized by architectural layer

### RSpec Integration
- Uses shared context `project_config` in spec_helper.rb that provides common collections (controllers, presenters, models, repos, actions, test_files)
- Lint rules are written as standard RSpec tests using Rubyzen's API

### GitHub Action Integration
- `action.yml` - GitHub Action for running Rubyzen analysis in CI/CD
- Configurable target directory and RSpec directory
- Outputs violations found and full analysis results

## Development Patterns

### Writing Lint Rules
Lint rules are written as RSpec tests using the shared context. Example pattern:
```ruby
describe 'Architectural Rule' do
  it 'enforces the rule' do
    expect(controllers.that { have_call_sites_with_names('.where') }).to be_empty
  end
end
```

### Path Filtering
Collections support path-based filtering:
- `.with_paths('src/controllers/')` - Include only files matching pattern
- `.without_paths('/spec/')` - Exclude files matching pattern

### Environment Configuration
The system requires `RUBYZEN_PROJECT_PATHS` (or `RUBYZEN_PROJECT_PATH` for single directory) to be set to the absolute path(s) of the project(s) to analyze. Multiple paths are colon-separated like the PATH environment variable. This allows the same Rubyzen installation to analyze different target projects and multiple directories within a project.