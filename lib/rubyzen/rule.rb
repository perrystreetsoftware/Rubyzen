module Rubyzen
  # Describes an architectural lint rule: what it requires, why, and how to fix a violation.
  #
  # Pass a +Rule+ to any Rubyzen matcher (+rule:+) or assertion (+rule:+) and the failure
  # message explains the rule instead of just listing the violations. This gives whoever reads
  # the failure — a developer or an AI agent — the context needed to fix the code rather than
  # to silence the rule.
  #
  # Define the sections in a block (see {Builder}) or pass them as keywords. Only +description+
  # is required; the other sections are omitted from the message when +nil+.
  #
  # @example Defining a rule with the block DSL and attaching it to an RSpec matcher
  #   let(:rule) do
  #     Rubyzen::Rule.new do
  #       description 'Controllers do not contain if statements.'
  #       rationale <<~TEXT
  #         Controllers only orchestrate; branching is business logic in the wrong layer.
  #       TEXT
  #       fix_hint 'Move the condition into a Service step and return a Failure.'
  #       bad_example <<~RUBY
  #         return error(:forbidden) if profile.banned?
  #       RUBY
  #       good_example <<~RUBY
  #         Services::Profiles::Update.new.call(profile:)
  #       RUBY
  #     end
  #   end
  #
  #   it 'has no if statements' do
  #     expect(controllers.all_methods.if_statements).to zen_empty(rule:)
  #   end
  #
  # @example Defining a short rule with keywords and attaching it to a Minitest assertion
  #   RULE = Rubyzen::Rule.new(description: 'Controllers do not contain if statements.')
  #
  #   assert_zen_empty(controllers.all_methods.if_statements, rule: RULE)
  #
  class Rule
    # @return [String] one-line statement of what the rule requires
    attr_reader :description

    # @return [String, nil] why the rule exists — the architectural reasoning
    attr_reader :rationale

    # @return [String, nil] how to bring violating code into compliance
    attr_reader :fix_hint

    # @return [String, nil] a short snippet that violates the rule
    attr_reader :bad_example

    # @return [String, nil] a short snippet that satisfies the rule
    attr_reader :good_example

    # @param description [String] one-line statement of what the rule requires
    # @param rationale [String, nil] why the rule exists
    # @param fix_hint [String, nil] how to fix a violation
    # @param bad_example [String, nil] a snippet that violates the rule
    # @param good_example [String, nil] a snippet that satisfies the rule
    # @yield the block DSL, evaluated by a {Builder}; use it instead of the keywords
    # @yieldparam builder [Builder] passed when the block declares a parameter
    # @raise [ArgumentError] if +description+ is blank, or if both keywords and a block are given
    def initialize(description: nil, rationale: nil, fix_hint: nil, bad_example: nil, good_example: nil, &definition)
      sections = { description:, rationale:, fix_hint:, bad_example:, good_example: }
      if definition
        raise ArgumentError, 'Rubyzen::Rule takes its sections as keywords or in a block, not both' if sections.values.any?

        sections = Builder.build(&definition)
      end

      @description = normalize_text(sections[:description])
      raise ArgumentError, 'Rubyzen::Rule requires a description' unless @description

      @rationale = normalize_text(sections[:rationale])
      @fix_hint = normalize_text(sections[:fix_hint])
      @bad_example = normalize_code(sections[:bad_example])
      @good_example = normalize_code(sections[:good_example])
      freeze
    end

    # Returns the human-readable failure text: the description followed by every
    # provided section, separated by blank lines.
    #
    # @return [String]
    #
    # @example
    #   rule.message
    #   #=> "RULE: Controllers do not contain if statements.\n\nWHY: ...\n\nHOW TO FIX: ..."
    def message
      [
        "RULE: #{description}",
        rationale && "WHY: #{rationale}",
        fix_hint && "HOW TO FIX: #{fix_hint}",
        bad_example && "BAD:\n#{bad_example}",
        good_example && "GOOD:\n#{good_example}"
      ].compact.join("\n\n")
    end
    alias to_s message

    private

    def normalize_text(value)
      text = value.to_s.strip
      text.empty? ? nil : text
    end

    # Keeps the indentation of code snippets and only drops surrounding blank lines,
    # so heredoc examples render as written.
    def normalize_code(value)
      code = value.to_s.sub(/\A(\s*\n)+/, '').rstrip
      code.empty? ? nil : code
    end

    # The block DSL of {Rule#initialize}: one method per section. The block is evaluated
    # with the builder as +self+, or receives it as a parameter (+do |rule| ... end+) when the
    # block needs to reach methods of the surrounding scope. Calling a method again replaces
    # the earlier value.
    #
    # @example
    #   Rubyzen::Rule.new do
    #     description 'Jobs are namespaced in the Jobs module.'
    #     fix_hint 'Wrap the class in `module Jobs`.'
    #   end
    class Builder
      # Evaluates a rule definition block.
      #
      # @return [Hash{Symbol => String}] the sections that the block defined
      def self.build(&definition)
        builder = new
        definition.arity == 1 ? definition.call(builder) : builder.instance_eval(&definition)
        builder.sections
      end

      # @return [Hash{Symbol => String}] the sections defined so far
      attr_reader :sections

      def initialize
        @sections = {}
      end

      # @param text [String] one-line statement of what the rule requires
      # @return [void]
      def description(text)
        @sections[:description] = text
      end

      # @param text [String] why the rule exists — the architectural reasoning
      # @return [void]
      def rationale(text)
        @sections[:rationale] = text
      end

      # @param text [String] how to bring violating code into compliance
      # @return [void]
      def fix_hint(text)
        @sections[:fix_hint] = text
      end

      # @param code [String] a short snippet that violates the rule
      # @return [void]
      def bad_example(code)
        @sections[:bad_example] = code
      end

      # @param code [String] a short snippet that satisfies the rule
      # @return [void]
      def good_example(code)
        @sections[:good_example] = code
      end
    end
  end
end
