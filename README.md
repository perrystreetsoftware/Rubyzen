# Rubyzen

Rubyzen is an architectural linter for Ruby that lets you write architectural lint rules as unit tests, inspired by tools like [Konsist](https://github.com/LemonAppDev/konsist) (for Kotlin) and [Harmonize](https://github.com/perrystreetsoftware/Harmonize) (for Swift).

## Architectural linters in the era of AI-generated code

In the era of AI-generated code, architectural flaws and subtle bugs happen faster than ever. AI agents produce code that passes tests and looks reasonable but subtly violates your team's architecture. As more code is produced, faster, it becomes impractical for manual code reviews to catch all these violations.

Architectural lint rules act as deterministic guardrails. They catch the architectural or structural mistakes that AI introduces, such as calling the database from a presenter or performing business logic in a controller, before they get merged. And since they run as unit tests, they provide immediate feedback to the AI agents to fix their own code.

## Why Yet Another Linter?

Traditional linters such as [RuboCop](https://github.com/rubocop/rubocop) require dealing with the raw AST, which has a steep learning curve and makes rules hard to write, read, and maintain. Rubyzen abstracts away the AST details, allowing developers to write rules in a more natural way — the same way we write tests.

## Advantages

- **Readable, Easy-to-Use API:** Rubyzen provides a high-level API to access files, classes, methods, parameters, and more, without having to deal with low-level AST operations.

- **Architectural Enforcement & Documentation:** By writing lint rules as tests, you can use the Given-When-Then style and document your architecture within the codebase, without maintaining wiki pages or diagrams.

- **Less Manual Reviews:** With architectural rules automatically enforced, code reviews can focus on complex issues instead of repeating the same architectural feedback.

- **AI-Friendly Feedback Loop:** When lint rules fail, the failure messages tell AI agents exactly what they violated and where, allowing them to self-correct their code.

## How it Works

Rubyzen uses [RuboCop AST](https://github.com/rubocop/rubocop-ast) under the hood to parse Ruby code into an AST. It then provides a simplified API to access classes, methods, or any other code structure. Since RuboCop AST can access any node or token, Rubyzen's API can cover any architectural rule you want to enforce.

## Example

```ruby
RSpec.describe 'Architecture rules' do
  it 'controllers do not call ActiveRecord directly' do
    violations = controllers
      .all_methods
      .call_sites
      .with_name('where')

    expect(violations).to be_empty
  end

  it 'all services inherit from BaseService' do
    expect(services).to be_true { |s| s.superclass_name == 'BaseService' }
  end
end
```

## Project Structure

- **`lib/rubyzen/`:** Rubyzen's source code — declarations, collections, providers, matchers, parsers, and cache
- **`sample_project/src/`:** A sample Ruby project with intentional violations
- **`sample_project/spec/`:** Sample lint rules demonstrating architectural enforcement

## Running tests

```bash
# Run unit tests (verify Rubyzen's own API works)
cd path/to/Rubyzen
bundle exec rspec spec/
```

## Running lint rules against the sample project

```bash
# Run lint rules on the sample project (expected to fail — intentional violations)
cd path/to/Rubyzen
bundle exec rspec sample_project/spec/
```

## Running lint rules against your own project

To run the lint rules against your own project, set the `RUBYZEN_PROJECT_PATHS` env var to the folders you want to lint, and then run `bundle exec rspec`:

```bash
cd path/to/Rubyzen
export RUBYZEN_PROJECT_PATHS="/path/to/your-project/src"
# Optionally include test files or other folders if you want to lint those too
# export RUBYZEN_PROJECT_PATHS="/path/to/your-project/src,/path/to/your-project/spec"
bundle exec rspec path/to/your-project-lint-rules
```

## AI Agent Skills

Rubyzen includes agent skills in `.claude/skills/` (also symlinked at `.github/skills/`) that work with both Claude Code and GitHub Copilot:

| Skill | Purpose |
|---|---|
| `run-tests` | Run Rubyzen's unit test suite |
| `run-lint-rules` | Run sample project lint rules and verify the violations are detected |
| `write-lint-rule` | Write an architectural lint rule using the Rubyzen API |
| `add-rubyzen-tests` | Write unit tests for Rubyzen's own components |
| `expand-rubyzen` | Add a new Rubyzen API (Declaration + Provider + Collection) |

## Dev Container (optional)

Rubyzen includes a dev container that automatically mounts a sibling project and configures the environment for you. See [`.devcontainer/README.md`](.devcontainer/README.md) for setup instructions.
