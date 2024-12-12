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

- **`lib`:** Contains Rubyzen’s source code, including:
  - `project.rb` and `class_analyzer.rb` to parse and represent the codebase.
  - Custom matchers that allows us to write the lint rules in an easy and intuitive way.

- **`sample_project/src`:** A sample Ruby project that Rubyzen is currently linting.

- **`sample_project/spec`:** Contains the lint rules, written as unit tests. These tests demonstrate how we can enforce the architectural rules of our team. Additionally, each lint rule has a real GitHub PR comment attached that can be now enforced by that rule.

## Example Lint Rules

- Ensuring that non-repository classes do not use `.where` queries.
- Verifying that presenter classes do not directly access repositories.
- Prohibiting new additions to legacy files.
- Confirming that model classes do not use question-mark in methods, enforcing us to use the Ask pattern.

## Setup

1. Clone the repository.
2. Install the dependencies: `bundle install`
3. Run the tests (lint rules): `bundle exec rspec sample_project/spec`

---

This project is an early prototype. The intent is to explore the technical feasibility and effort to build a modern architectural linter for Ruby.
