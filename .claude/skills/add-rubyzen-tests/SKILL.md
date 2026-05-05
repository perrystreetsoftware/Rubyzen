---
name: add-rubyzen-tests
description: Write unit tests for Rubyzen's own API components — declarations, providers, collections, or matchers. Use this skill when the user wants to add tests for an existing or newly added Rubyzen component, increase test coverage, or write specs for untested methods. Also trigger when the user says "test this declaration", "add specs for", or "write tests for the X collection".
---

# Writing Unit Tests for Rubyzen

You are writing unit tests for Rubyzen's internal API — the declarations, providers, collections, and matchers that make up the library. These tests verify that Rubyzen's own code works correctly.

**This is NOT about writing lint rules.** Lint rules test user codebases; unit tests test Rubyzen itself. Use the `write-lint-rule` skill for lint rules.

## Step 0: Understand the Test Infrastructure

Read these files first:

1. `spec/spec_helper.rb` — test configuration
2. `spec/support/parse_helper.rb` — the `parse_ruby` helper
3. An existing spec similar to what you're testing (e.g., `spec/declarations/class_declaration_spec.rb`)

The `parse_ruby` helper is the foundation of all tests:

```ruby
def parse_ruby(source, file_path: 'test.rb')
  processed = RuboCop::AST::ProcessedSource.new(source, RUBY_VERSION.to_f, file_path)
  Rubyzen::Declarations::FileDeclaration.new(file_path, processed.ast)
end
```

It takes an inline Ruby string and returns a `FileDeclaration`, bypassing file I/O.

## Critical: The Single-Statement AST Gotcha

When a Ruby snippet has **only one statement**, the AST root node IS that statement. Providers use `node.each_descendant` which only searches children — so the root node is invisible.

```ruby
# BAD — single statement, root IS the :casgn node
file = parse_ruby('MAX = 100')
file.constants  # => empty! each_descendant can't find the root

# GOOD — two statements, root is :begin wrapper
file = parse_ruby("MAX = 100\nx = 1")
file.constants  # => [ConstantDeclaration(MAX)]
```

**Always include at least two statements** in snippets that test file-level providers (`constants`, `requires`, `blocks`, `call_sites`). This does NOT affect class/method-level tests since those always have wrapper nodes.

## Writing Declaration Specs

File: `spec/declarations/<concept>_declaration_spec.rb`

**Test every public method** on the declaration. Group related methods.

```ruby
require 'spec_helper'

RSpec.describe Rubyzen::Declarations::<Concept>Declaration do
  describe '#name' do
    it 'returns the declaration name' do
      file = parse_ruby(<<~RUBY)
        class Foo
          def bar
            # code containing the concept
          end
        end
      RUBY

      decl = file.classes.first.instance_methods.first.<concepts>.first
      expect(decl.name).to eq('expected')
    end
  end

  # Test every other public method in its own describe block...

  # Always test provider-inherited methods:
  describe '#file_path' do
    it 'returns the file path' do
      file = parse_ruby(<<~RUBY, file_path: 'app/models/user.rb')
        class User
          def foo
            # concept here
          end
        end
      RUBY

      decl = file.classes.first.instance_methods.first.<concepts>.first
      expect(decl.file_path).to eq('app/models/user.rb')
    end
  end

  describe '#line' do
    it 'returns the line number' do
      file = parse_ruby(<<~RUBY)
        class Foo
          def bar
            # concept on line 3
          end
        end
      RUBY

      decl = file.classes.first.instance_methods.first.<concepts>.first
      expect(decl.line).to eq(3)
    end
  end

  describe '#class_name' do
    it 'returns the enclosing class name' do
      file = parse_ruby(<<~RUBY)
        class Foo
          def bar
            # concept here
          end
        end
      RUBY

      decl = file.classes.first.instance_methods.first.<concepts>.first
      expect(decl.class_name).to eq('Foo')
    end
  end
end
```

## Writing Collection Specs

File: `spec/collections/<concepts>_collection_spec.rb`

Test three categories:

1. **CollectionFilterProvider methods** (`with_name`, `without_name`, etc.)
2. **Domain-specific filter methods** (e.g., `with_receiver`, `with_exception_type`)
3. **Type preservation** — `filter` returns the same collection type

```ruby
require 'spec_helper'

RSpec.describe Rubyzen::Collections::<Concepts>Collection do
  # CollectionFilterProvider
  describe '#with_name' do
    it 'filters by exact name' do
      file = parse_ruby(<<~RUBY)
        class Foo
          def bar
            # two concepts with different names
          end
        end
      RUBY

      collection = file.classes.first.instance_methods.first.<concepts>
      result = collection.with_name('target')
      expect(result.size).to eq(1)
      expect(result.first.name).to eq('target')
    end
  end

  # Domain-specific filters
  describe '#with_custom_filter' do
    it 'filters by custom criteria' do
      # ...
    end
  end

  # Type preservation
  describe '#filter' do
    it 'returns the same collection type' do
      file = parse_ruby(<<~RUBY)
        class Foo
          def bar
            # concept here
          end
        end
      RUBY

      collection = file.classes.first.instance_methods.first.<concepts>
      result = collection.filter { |d| d.name == 'something' }
      expect(result).to be_a(described_class)
    end
  end

  # Bridge methods (if collection has them)
  describe '#sub_collection' do
    it 'aggregates sub-declarations into typed collection' do
      # ...
    end
  end
end
```

## Writing Matcher Specs

File: `spec/matchers/<matcher_name>_matcher_spec.rb`

Test pass and fail cases. Use `raise_error(RSpec::Expectations::ExpectationNotMetError)` to test failure:

```ruby
require 'spec_helper'

RSpec.describe 'be_empty matcher' do
  it 'passes when collection is empty' do
    file = parse_ruby(<<~RUBY)
      class Foo
        def bar; end
      end
    RUBY

    # Get an empty collection
    collection = file.classes.first.instance_methods.first.call_sites
    expect(collection).to be_empty
  end

  it 'fails when collection is not empty' do
    file = parse_ruby(<<~RUBY)
      class Foo
        def bar
          puts "hello"
        end
      end
    RUBY

    collection = file.classes.first.instance_methods.first.call_sites
    expect {
      expect(collection).to be_empty
    }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
  end
end
```

**Note:** Do NOT use `fail_with` — it's not available. Use `raise_error(RSpec::Expectations::ExpectationNotMetError, /pattern/)` to test failure messages.

## When to Use Fixture Files

Use `spec/fixtures/` with real `.rb` files only when testing:
- `Project.new(paths)` — needs real file paths
- `FileCollection#with_paths` / `#without_paths` — path matching
- `ParseCache` — file-based caching

For everything else, use inline `parse_ruby` snippets.

## Test Snippet Best Practices

1. **Minimal snippets** — include only the Ruby code needed for the test
2. **Realistic names** — use realistic class/method names, not `Foo`/`bar` (when the name matters for the test)
3. **Multiple cases** — test edge cases (empty, nil, multiple items)
4. **Two+ statements** — for file-level concepts (see gotcha above)

## Checklist

- [ ] Spec file follows naming convention: `spec/<layer>/<concept>_spec.rb`
- [ ] Requires `spec_helper`
- [ ] Tests every public method on the class
- [ ] Tests provider-inherited methods (`file_path`, `line`, `class_name`)
- [ ] Tests `CollectionFilterProvider` methods for collections
- [ ] Tests type preservation for collection `filter`
- [ ] Snippets have 2+ statements when testing file-level providers
- [ ] Does NOT use `fail_with` (uses `raise_error` instead)
- [ ] `bundle exec rspec spec/` passes
