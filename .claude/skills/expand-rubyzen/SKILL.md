---
name: expand-rubyzen
description: Add a new code concept to Rubyzen — a new Declaration, Provider, and Collection as a full vertical slice. Use this skill whenever the user wants to add support for a new Ruby language construct (e.g., case statements, loops, yield calls, begin/end blocks, lambda expressions), add a new API to the library, or extend Rubyzen's analysis capabilities. Also use when the user says "add support for X" or "I want to lint on X" where X is a code structure not yet modeled.
---

# Expanding Rubyzen with a New Code Concept

You are adding a new code concept to Rubyzen — a Ruby architectural linter that wraps RuboCop AST with a high-level API. Every new concept follows a **vertical slice**: Declaration → Provider → Collection → Tests → Wiring.

## Step 0: Understand the Architecture First

Before writing any code, read these files to understand current patterns:

1. `CLAUDE.md` — full architecture guide
2. An existing declaration similar to what you're adding (e.g., `lib/rubyzen/declarations/call_site_declaration.rb`)
3. Its corresponding provider (e.g., `lib/rubyzen/providers/call_site_provider.rb`)
4. Its corresponding collection (e.g., `lib/rubyzen/collections/call_site_collection.rb`)
5. Its unit test (e.g., `spec/declarations/call_site_declaration_spec.rb`)

This gives you the exact patterns to follow. Do not invent new patterns.

## Step 1: Identify the AST Node Type

Use RuboCop AST to determine which node type(s) represent the concept. You can test interactively:

```ruby
source = "your ruby code here"
processed = RuboCop::AST::ProcessedSource.new(source, RUBY_VERSION.to_f)
processed.ast  # inspect the AST
```

Common node types: `:send`, `:block`, `:if`, `:case`, `:while`, `:for`, `:yield`, `:return`, `:const`, `:casgn`, `:def`, `:defs`, `:class`, `:module`, `:resbody`, `:kwbegin`.

## Step 2: Create the Declaration

Create `lib/rubyzen/declarations/<concept>_declaration.rb`.

**Mandatory structure:**

```ruby
module Rubyzen
  module Declarations
    # YARD: Brief description of what this represents.
    #
    # @example
    #   decl = method.<concepts>.first
    #   decl.name #=> "example"
    #
    class <Concept>Declaration
      # Always include these three for matcher output:
      include Rubyzen::Providers::FilePathProvider
      include Rubyzen::Providers::LineNumberProvider
      include Rubyzen::Providers::ClassNameProvider

      # Include additional providers based on what makes sense:
      # include Rubyzen::Providers::SourceCodeProvider    # if source_code is useful
      # include Rubyzen::Providers::LinesOfCodeProvider   # if lines_of_code is useful
      # include Rubyzen::Providers::CallSiteProvider      # if it can contain method calls
      # include Rubyzen::Providers::BlocksProvider        # if it can contain blocks
      # include Rubyzen::Providers::RescuesProvider       # if it can contain rescue clauses
      # include Rubyzen::Providers::RaisesProvider        # if it can contain raise statements

      # @return [RuboCop::AST::Node]
      attr_reader :node

      # @return [MethodDeclaration, ClassDeclaration, ...] adjust type based on valid parents
      attr_reader :parent

      # @param node [RuboCop::AST::Node] the AST node
      # @param parent [...] the parent declaration
      def initialize(node, parent)
        @node = node
        @parent = parent
      end

      # NOTE on parent naming: Most declarations use `parent`, but some use
      # domain-specific names with an alias:
      #   - MethodDeclaration: `parent_class` (alias :parent :parent_class)
      #   - ClassDeclaration: `file_declaration` (no alias — uses `file_declaration`)
      #   - RequireDeclaration: `parent_file` (alias :parent :parent_file)
      # FilePathProvider traverses via `parent`, `file_declaration`, and `parent_class`,
      # so if you use a custom name, add `alias :parent :<custom_name>` to ensure
      # FilePathProvider can walk the tree.

      # REQUIRED: Used by matchers for failure messages.
      # @return [String]
      def name
        # Return a meaningful identifier for this declaration
      end

      # Add domain-specific public methods here.
      # Each must have YARD @return tags.
    end
  end
end
```

**Rules:**
- `node` and `parent` are always `attr_reader` — providers depend on them
- `FilePathProvider`, `LineNumberProvider`, `ClassNameProvider` are **required** — matchers use `file_path`, `line`, and `class_name` for failure messages
- A `name` method is **required** — matchers call it via `element_name`
- Zeitwerk autoloads — no `require` statements needed (exception: if the file is loaded before Zeitwerk, add explicit `require_relative`)

## Step 3: Create the Provider

Create `lib/rubyzen/providers/<concepts>_provider.rb` (plural name).

```ruby
module Rubyzen
  module Providers
    # YARD: Brief description.
    module <Concepts>Provider
      # @return [<Concepts>Collection]
      def <concepts>
        matching_nodes = node.each_descendant(:<node_type>).select do |n|
          # optional filtering condition
          true
        end

        declarations = matching_nodes.map do |n|
          Declarations::<Concept>Declaration.new(n, self)
        end

        Collections::<Concepts>Collection.new(declarations)
      end
    end
  end
end
```

**Rules:**
- The method name is plural (e.g., `yields`, `case_statements`, `loops`)
- Always returns a typed Collection, never a raw Array
- Uses `node.each_descendant` to find relevant AST nodes
- Creates declarations with `self` as parent so `FilePathProvider` can traverse upward

## Step 4: Create the Collection

Create `lib/rubyzen/collections/<concepts>_collection.rb`.

```ruby
module Rubyzen
  module Collections
    # YARD: Brief description.
    #
    # @example
    #   <concepts> = method.<concepts>
    #   <concepts>.with_name("foo")
    #
    class <Concepts>Collection < BaseCollection
      include Rubyzen::Providers::CollectionFilterProvider

      # Add domain-specific filter methods here.
      # Each filter method MUST use `filter` (not `select` or `reject`).
      # `filter` preserves the collection type for chaining.

      # @param some_value [String]
      # @return [<Concepts>Collection]
      def with_some_filter(some_value)
        filter { |decl| decl.some_method == some_value }
      end
    end
  end
end
```

**Rules:**
- Always extend `BaseCollection`
- Always include `CollectionFilterProvider` (provides `with_name`, `without_name`, etc.)
- Filter methods use `filter { }`, **never** `select` or `reject` (they are undefined on BaseCollection)
- Filter methods return the same collection type (this happens automatically via `filter`)

## Step 5: Wire It Up

Include the provider in the declarations that should expose this concept:

```ruby
# In the declaration file, add:
include Rubyzen::Providers::<Concepts>Provider
```

**Where to include it** — think about where this concept appears in Ruby code:
- In method bodies → include in `MethodDeclaration`
- In class bodies → include in `ClassDeclaration`
- In blocks → include in `BlockDeclaration`
- At file level → include in `FileDeclaration`
- Multiple places → include in all relevant declarations

**Add bridge methods** to collections that should aggregate the data:

```ruby
# In methods_collection.rb (if provider is on MethodDeclaration):
def <concepts>
  <Concepts>Collection.new(flat_map(&:<concepts>))
end
```

Add bridge methods to every collection whose elements include the provider. For example:
- If `MethodDeclaration` includes the provider → add bridge to `MethodsCollection`
- If `ClassDeclaration` includes the provider → add bridge to `ClassesCollection`
- Users chain upward naturally: `classes.all_methods.<concepts>` works without a bridge on `ClassesCollection` because the bridge is on `MethodsCollection`

Only add a bridge to a collection if its elements **directly** have the provider. Don't add redundant bridges that just delegate through another bridge.

## Step 6: Write Tests

### Declaration spec (`spec/declarations/<concept>_declaration_spec.rb`)

```ruby
require 'spec_helper'

RSpec.describe Rubyzen::Declarations::<Concept>Declaration do
  # Test every public method on the declaration.
  # Use inline Ruby snippets via parse_ruby helper.

  it 'returns the name' do
    file = parse_ruby(<<~RUBY)
      class Foo
        def bar
          # ruby code that contains the concept
        end
      end
    RUBY

    decl = file.classes.first.instance_methods.first.<concepts>.first
    expect(decl.name).to eq('expected_name')
  end

  # Test all other public methods...

  # Test provider methods (file_path, line, class_name, source_code, etc.)
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
```

### Collection spec (`spec/collections/<concepts>_collection_spec.rb`)

```ruby
require 'spec_helper'

RSpec.describe Rubyzen::Collections::<Concepts>Collection do
  # Test CollectionFilterProvider methods
  it 'filters by name' do
    # ...
    expect(collection.with_name('target')).to contain_exactly(...)
  end

  # Test domain-specific filter methods
  it 'filters with custom filter' do
    # ...
  end

  # Test that filter returns same collection type
  it 'returns the same collection type from filter' do
    # ...
    expect(result).to be_a(described_class)
  end
end
```

### Critical testing gotcha

**Single-statement AST root:** When a Ruby snippet has only one statement, the AST root IS that statement. `each_descendant` won't find it because it only searches children, not the root itself. Always include at least two statements:

```ruby
# BAD — yields nothing because root IS the :send node
file = parse_ruby('require "json"')
file.requires  # => empty!

# GOOD — root is :begin, each_descendant finds both children
file = parse_ruby("require 'json'\nx = 1")
file.requires  # => [RequireDeclaration]
```

This affects any provider that uses `each_descendant` on file-level nodes.

## Step 7: Update Documentation

1. Add the new declaration to the **Declaration Reference** table in `CLAUDE.md`
2. Add the new collection to the **Data Flow** tree in `CLAUDE.md`
3. Run `bundle exec rspec spec/` to verify all tests pass

## Checklist

Before considering the work complete, verify:

- [ ] Declaration includes `FilePathProvider`, `LineNumberProvider`, `ClassNameProvider`
- [ ] Declaration has a `name` method
- [ ] Declaration has `attr_reader :node, :parent`
- [ ] All public methods have YARD `@return` tags
- [ ] Provider method returns a typed Collection (not Array)
- [ ] Collection extends `BaseCollection` and includes `CollectionFilterProvider`
- [ ] Collection filter methods use `filter` (not `select`/`reject`)
- [ ] Provider is included in all relevant declarations
- [ ] Bridge methods added to parent collections
- [ ] Declaration spec tests every public method
- [ ] Collection spec tests `CollectionFilterProvider` methods and domain-specific filters
- [ ] Test snippets have 2+ statements (single-statement gotcha)
- [ ] `CLAUDE.md` updated
- [ ] `bundle exec rspec spec/` passes
