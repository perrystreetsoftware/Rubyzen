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

## Setup

1. Clone the repository.
2. Install the dependencies: `bundle install`
3. Run the tests (lint rules): `bundle exec rspec sample_project/spec`

## Dev Container Integration

Rubyzen includes dev container support that automatically mounts external projects for linting. The configuration uses:

- **Environment Variable**: `RUBYZEN_TARGET_PROJECT` specifies which sibling project to lint (defaults to `Husband-Redis`)
- **Fixed Mount Point**: Target project is mounted to `/workspaces/Rubyzen/target_project`
- **Static Configuration**: `.rubyzen.yaml` always points to `/workspaces/Rubyzen/target_project/src`

### Quick Start

1. **Set target project** (optional):
   ```bash
   export RUBYZEN_TARGET_PROJECT=YourProjectName
   ```

2. **Open in dev container**:
   ```bash
   code .
   ```

### Project Structure in Container

```
/workspaces/Rubyzen/
├── lib/                     (Rubyzen source code)
├── sample_project/          (Sample project to lint)
│   ├── src/                 (Sample Ruby source files)
│   └── spec/                (Sample lint rules)
└── target_project/          (External project mounted here)
    ├── src/                 (External Ruby source files)
    └── spec/rubyzen/        (Project-specific lint rules)
```

### Usage Examples

```bash
# Lint Husband-Redis (default)
code .

# Lint different project
RUBYZEN_TARGET_PROJECT=MyClientApp code .

# Lint another project
RUBYZEN_TARGET_PROJECT=SomeOtherProject code .
```

### Requirements

- Target project must be a **sibling directory** to RubyZen
- Target project should have a `src/` subdirectory with Ruby files
- Directory structure example:
  ```
  parent-folder/
  ├── Rubyzen/           (this project)
  ├── Husband-Redis/     (target project)
  └── MyOtherProject/    (another target project)
  ```

### Running Lint Rules

**For sample project (using Rubyzen's sample code):**
```bash
bundle exec rspec sample_project/spec/
```

**For external target project:**
```bash
bundle exec rspec target_project/spec/rubyzen/
```

### Team Setup

Create a `.env` file for consistent team configuration:

```bash
# .env
RUBYZEN_TARGET_PROJECT=OurMainProject
```

### Troubleshooting

**"Target project path not found" Warning**
- Check: Is `RUBYZEN_TARGET_PROJECT` set correctly?
- Check: Does `../$RUBYZEN_TARGET_PROJECT` exist on your host?
- Try: Rebuilding the dev container

---

This project is an early prototype. The intent is to explore the technical feasibility and effort to build a modern architectural linter for Ruby.
