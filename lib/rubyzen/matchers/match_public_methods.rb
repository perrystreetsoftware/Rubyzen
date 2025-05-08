require_relative 'matcher_helpers'

RSpec::Matchers.define :match_public_methods do |method_names:, optional_method_names: [], message: nil|
  include Rubyzen::Matchers::MatcherHelpers

  match do |classes_collection|
    @custom_message = message
    @method_names = method_names.map(&:to_s)
    @optional_method_names = optional_method_names.map(&:to_s)
    @classes_collection = classes_collection

    @offenders_extra_methods = []
    @offenders_missing_methods = []
    @class_to_extra_methods = {}
    @class_to_missing_methods = {}

    # Check each class declaration for required and optional methods
    @classes_collection.each do |class_decl|
      public_methods = class_decl.methods.map { |m| m.public_method? ? m.name : nil }.compact

      # Check for extra methods
      extra_methods = public_methods.select do |method_name|
        !@method_names.include?(method_name) && !@optional_method_names.include?(method_name)
      end

      if extra_methods.any?
        @offenders_extra_methods << class_decl
        @class_to_extra_methods[class_decl] = extra_methods
      end

      # Check for missing required methods
      missing_methods = @method_names.select { |method| !public_methods.include?(method) }

      if missing_methods.any?
        @offenders_missing_methods << class_decl
        @class_to_missing_methods[class_decl] = missing_methods
      end
    end

    # Classes must have exactly the specified required methods - no extras, no missing ones
    # Optional methods are allowed to be present or absent
    @offenders_extra_methods.empty? && @offenders_missing_methods.empty?
  end

  match_when_negated do |classes_collection|
    @custom_message = message
    @method_names = method_names.map(&:to_s)
    @optional_method_names = optional_method_names.map(&:to_s)
    @classes_collection = classes_collection
    @negated_offenders = []
    @class_to_methods = {}

    # For negated matcher, we track classes that have exactly the required methods
    # (all required methods present, no extra methods except optional ones)
    classes_collection.each do |class_decl|
      public_methods = class_decl.methods.map { |m| m.public_method? ? m.name : nil }.compact

      # All required methods must be present
      has_all_required = @method_names.all? { |e| public_methods.include?(e) }

      # No extra methods except optional ones
      has_no_extras = public_methods.all? do |method_name|
        @method_names.include?(method_name) || @optional_method_names.include?(method_name)
      end

      if has_all_required && has_no_extras
        @negated_offenders << class_decl
        @class_to_methods[class_decl] = public_methods
      end
    end

    @negated_offenders.empty?
  end

  failure_message do |_classes_collection|
    message_for_failure(@custom_message || formatted_failure_message(negated: false))
  end

  failure_message_when_negated do |_classes_collection|
    optional_str = @optional_method_names.any? ? " (with optional methods: #{@optional_method_names.join(', ')})" : ""

    details = @negated_offenders.map do |cls|
      methods = @class_to_methods[cls]
      "#{cls.name_with_modules} (file: #{cls.file_path}) (methods: #{methods.join(', ')})"
    end.join("\n")

    message_for_failure(@custom_message || "Expected classes not to have exactly these public methods: #{@method_names.join(', ')}#{optional_str}.\nViolating classes:\n#{details}")
  end

  private

  def formatted_failure_message(negated:)
    extra_msg = extra_methods_message(negated:)
    missing_msg = missing_methods_message(negated:)

    if !@offenders_extra_methods.empty? && !@offenders_missing_methods.empty?
      "#{extra_msg}\n\n#{missing_msg}"
    elsif !@offenders_extra_methods.empty?
      extra_msg
    else
      missing_msg
    end
  end

  def extra_methods_message(negated:)
    optional_str = @optional_method_names.any? ? " (optional: #{@optional_method_names.join(', ')})" : ""

    details = @offenders_extra_methods.map do |cls|
      extra = @class_to_extra_methods[cls]
      "#{cls.file_path}: (extra methods: #{extra.join(', ')})"
    end.join("\n")

    "Expected class to#{negated ? ' not ' : ' '}only have these public methods: #{@method_names.join(', ')}#{optional_str}.\nClasses with extra methods:\n#{details}"
  end

  def missing_methods_message(negated:)
    details = @offenders_missing_methods.map do |cls|
      missing = @class_to_missing_methods[cls]
      "#{cls.file_path}: (missing methods: #{missing.join(', ')})"
    end.join("\n")

    "Expected class to#{negated ? ' not ' : ' '}have all these public methods: #{@method_names.join(', ')}.\nClasses missing methods:\n#{details}"
  end

  def offenders_extra_methods_class_names
    @offenders_extra_methods.map { |o| o.name_with_modules }
  end

  def offenders_missing_methods_class_names
    @offenders_missing_methods.map { |o| o.name_with_modules }
  end
end