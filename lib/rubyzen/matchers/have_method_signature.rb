require 'rubocop-ast'
require_relative 'matcher_helpers'

RSpec::Matchers.define :have_method_signature do |method:, signature: :any, visibility: :any, message: nil|
  include Rubyzen::Matchers::MatcherHelpers

  match do |classes_collection|
    @custom_message       = message
    @method_name          = method.to_s
    @signature_str        = signature
    @visibility           = visibility
    @check_signature      = signature != :any
    @check_visibility     = visibility != :any
    @offenders            = []
    @classes_collection   = classes_collection

    @offenders_missing_method = []
    @offenders_wrong_signature = []
    @offenders_wrong_visibility = []

    # Only parse signature if we're checking it
    if @check_signature
      # Parse expected signature into AST args node
      sig_code      = "def #{@method_name}(#{@signature_str}); end"
      processed     = RuboCop::AST::ProcessedSource.new(sig_code, RUBY_VERSION.to_f, '(signature)')
      def_node      = processed.ast
      @expected_args = def_node.arguments
    end

    # Check each class declaration, including inherited methods
    @classes_collection.each do |class_decl|
      method_decl = class_decl.methods_including_inherited.find { |m| m.name == @method_name }

      if method_decl.nil?
        @offenders_missing_method << class_decl
      else
        # Check signature if needed
        if @check_signature && @expected_args != method_decl.node.arguments
          @offenders_wrong_signature << class_decl
        end

        # Check visibility if needed
        if @check_visibility
          is_public = method_decl.public_method?
          expected_public = (@visibility == :public)

          if is_public != expected_public
            @offenders_wrong_visibility << class_decl
          end
        end
      end
    end

    @offenders_missing_method.empty? &&
      (@check_signature ? @offenders_wrong_signature.empty? : true) &&
      (@check_visibility ? @offenders_wrong_visibility.empty? : true)
  end

  match_when_negated do |classes_collection|
    @custom_message     = message
    @method_name        = method.to_s
    @signature_str      = signature
    @visibility         = visibility
    @check_signature    = signature != :any
    @check_visibility   = visibility != :any
    @classes_collection = classes_collection
    @negated_offenders  = []

    # Only parse signature if we're checking it
    if @check_signature
      # Parse expected signature into AST args node
      sig_code      = "def #{@method_name}(#{@signature_str}); end"
      processed     = RuboCop::AST::ProcessedSource.new(sig_code, RUBY_VERSION.to_f, '(signature)')
      def_node      = processed.ast
      @expected_args = def_node.arguments
    end

    # For negated matcher, we track classes that DO have the method with correct signature and visibility
    # since those are the ones that fail the negated expectation
    classes_collection.each do |class_decl|
      method_decl = class_decl.methods_including_inherited.find { |m| m.name == @method_name }

      if method_decl
        # Check if method matches our criteria (both signature and visibility if applicable)
        matches_signature = !@check_signature || @expected_args == method_decl.node.arguments
        matches_visibility = !@check_visibility ||
                            (@visibility == :public) == method_decl.public_method?

        if matches_signature && matches_visibility
          @negated_offenders << class_decl
        end
      end
    end

    @negated_offenders.empty?
  end

  failure_message do
    visibility_str = @check_visibility ? "#{@visibility} " : ""

    message = if @check_signature
                "Expected classes to have #{visibility_str}method #{@method_name} with signature (#{@signature_str}). \n\n"
              else
                "Expected classes to have #{visibility_str}method #{@method_name} (any signature). \n\n"
              end

    message_for_failure(message + "#{methods_missing_message}#{methods_wrong_signature_message}#{methods_wrong_visibility_message}")
  end

  failure_message_when_negated do
    visibility_str = @check_visibility ? "#{@visibility} " : ""

    message = if @check_signature
                "Expected classes not to have #{visibility_str}method #{@method_name} with signature (#{@signature_str})"
              else
                "Expected classes not to have #{visibility_str}method #{@method_name} (any signature)"
              end

    message_for_failure(
      "#{message}, but found it in:\n" \
      "#{@negated_offenders.map do |cls|
         "#{cls.name_with_modules}, #{cls.file_path}"
       end.join("\n")}"
    )
  end

  private

  def methods_missing_message
    return '' unless @offenders_missing_method.any?

    "Method missing in: \n" \
      "#{@offenders_missing_method.map do |cls|
         "#{cls.file_path}"
       end.join("\n")}\n\n"
  end

  def methods_wrong_signature_message
    return '' unless @check_signature && @offenders_wrong_signature.any?

    "Method with wrong signature in: \n" \
    "#{@offenders_wrong_signature.map do |cls|
        "#{cls.file_path}"
      end.join("\n")}\n\n"
  end

  def methods_wrong_visibility_message
    return '' unless @check_visibility && @offenders_wrong_visibility.any?

    expected = @visibility.to_s
    actual = @visibility == :public ? "private" : "public"

    "Method with wrong visibility (expected #{expected}, got #{actual}) in: \n" \
    "#{@offenders_wrong_visibility.map do |cls|
        "#{cls.file_path}"
      end.join("\n")}\n\n"
  end
end