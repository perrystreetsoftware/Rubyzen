# Contributing to Rubyzen

## Setup

```bash
git clone https://github.com/perrystreetsoftware/Rubyzen.git
cd Rubyzen
bundle install
```

## Running Tests

```bash
# Rubyzen's unit tests
bundle exec rspec spec/

# Sample project lint rules (expected to fail — intentional violations)
bundle exec rspec sample_project/spec/
```

## Project Structure

- **`lib/rubyzen/`** — Source code (declarations, collections, providers, matchers, parsers, cache)
- **`spec/`** — Unit tests for Rubyzen's own API
- **`sample_project/`** — Sample app with intentional violations and lint rules demonstrating Rubyzen

## Making Changes

1. Fork the repository
2. Create a branch (`git checkout -b my-change`)
3. Make your changes
4. Run the tests (`bundle exec rspec spec/`)
5. Commit and push
6. Open a Pull Request

## Guidelines

- Follow existing code patterns (Declarations, Collections, Providers architecture)
- Add tests for new features
- Keep the API surface minimal and consistent
- Use YARD comments on public methods
