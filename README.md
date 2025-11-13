# Rubyzen

Rubyzen is a prototype of a modern linter in Ruby that lets you write architectural lint rules as unit tests, inspired by tools like [Konsist](https://github.com/LemonAppDev/konsist) (for Kotlin) and [Harmonize](https://github.com/perrystreetsoftware/Harmonize) (for Swift). The goal is to explore the technical feasibility and the effort required to build such linter.

## Motivation

Code review feedback often includes architectural or structural comments ("Do not call repository methods from presenters", "Do not query the database from controllers", etc.). With Rubyzen, you can enforce these architectural rules as unit tests. This reduces the need for manual code reviews and allows the team to align and document their architecture and best practices.

## Why Yet Another Linter?

Traditional linters such as [RuboCop](https://github.com/rubocop/rubocop) require dealing with the raw AST, which has a steep learning curve and makes the rules hard to write, hard to read, and maintain. The goal of Rubyzen is to abstract away the AST details, allowing developers to write rules in a more natural way, similarly as we write tests. This reduces complexity and improves readability and maintainability.

## Advantages

- **Easy-to-Use API:** Rubyzen provides a friendly, high-level API to access files, classes, methods, dependencies, and more. This way developers do not have to manual access nodes and deal with low-level AST operations manually.

- **Architectural Enforcement & Documentation:** By writing the lint rules as tests, we can use the Given-When-Then style and provide documentation for our architecture within the codebase, without having to maintain wiki pages or diagrams.

- **Less Manual Reviews:** With architectural rules automatically enforced by tests, code reviews can focus on more complex issues instead of repeating the same architectural feedback.

## How it Works

Rubyzen uses [RuboCop AST](https://github.com/rubocop/rubocop-ast) under the hood to parse the Ruby code into an AST. It then provides a simplified API to access classes, methods, dependencies, and other code structures. Since RuboCop AST can access any node or token, the API of Rubyzen can potentially cover any architectural rule that we want to enforce.

## Project Structure

- **`lib/rubyzen/`:** Contains Rubyzen's source code, including:
  - `project.rb` - Main project analyzer
  - `classes_collection.rb`, `methods_collection.rb`, `file_collection.rb` - Collections for code structures
  - `parsers/`, `matchers/`, `providers/`, `declarations/`, `cache/` - Core functionality modules

- **`sample_project/src/`:** A sample Ruby project that Rubyzen can lint

- **`sample_project/spec/`:** Contains sample lint rules written as unit tests, demonstrating how to enforce architectural rules

## Example Lint Rules

- Ensuring that non-repository classes do not use `.where` queries.
- Verifying that presenter classes do not directly access repositories.
- Prohibiting new additions to legacy files.
- Confirming that model classes do not use question-mark in methods, enforcing us to use the Ask pattern.

### Running Lint Rules
To run lint rules, execute RSpec with the path to your rule specifications. The rules will analyze the currently mounted target project:

```bash
# Run sample lint rules against the target project
bundle exec rspec sample_project/spec/

# Run custom lint rules for the target project
bundle exec rspec target_project/spec/rubyzen/
```

The lint rules are project-agnostic - you can apply any rule set to any target project by specifying the appropriate spec path.

## Dev Container Integration

### Quick Start

1. **Set target project environment variable** (REQUIRED):
   ```bash
   export RUBYZEN_TARGET_PROJECT=YourProjectName
   code .
   ```

**Note:** When changing the `RUBYZEN_TARGET_PROJECT` environment variable, you must rebuild the dev container for the change to take effect. The container will continue to mount the previous target directory until rebuilt.

### Architecture

**Environment-driven setup** - no configuration generation needed:
- `RUBYZEN_TARGET_PROJECT` environment variable specifies which sibling project to lint
- Target project mounts to fixed path: `/workspaces/target_project`
- All configs use static paths pointing to multiple directories: `/workspaces/target_project/src,/workspaces/target_project/spec`

#### Directory Structure
```
parent-folder/
├── Rubyzen/           (this linter project)
├── YourProject/       (target project - set via env var)
└── OtherProject/      (another potential target)
```

#### Container Structure
```
/workspaces/
├── Rubyzen/           (this project)
└── target_project/    (mounted from $RUBYZEN_TARGET_PROJECT)
    ├── src/           (Ruby source files to lint)
    └── spec/          (Ruby test files to lint)
```

### Usage Examples

```bash
# Different projects
export RUBYZEN_TARGET_PROJECT=Husband-Redis && code .
export RUBYZEN_TARGET_PROJECT=MyClientApp && code .

# Team setup with .env file
echo "RUBYZEN_TARGET_PROJECT=OurMainProject" > .env
```

### Troubleshooting

| Issue | Solution |
|-------|----------|
| "Environment variable not set" error | `export RUBYZEN_TARGET_PROJECT=YourProject` before `code .` |
| "Target project not found" | Verify `../$RUBYZEN_TARGET_PROJECT` exists and rebuild container |
| Mount errors on startup | Check env var is set, target exists, then rebuild container |
| Changed env var but still seeing old project | Rebuild dev container to update mount path |


This project is an early prototype. The intent is to explore the technical feasibility and effort to build a modern architectural linter for Ruby.
