module Rubyzen
  # Shared helper methods for Rubyzen's +zen_*+ / +assert_zen_*+ expectations —
  # used by both the RSpec matchers ({Rubyzen::Matchers}) and the Minitest
  # assertions ({Rubyzen::Assertions}).
  #
  # Provides utilities for normalizing exception lists, extracting item details,
  # matching items against allowlist/baseline entries, and formatting failure
  # messages. These methods are framework-agnostic — they operate only on plain
  # declaration objects and instance variables set by the caller.
  module ExpectationHelpers
    # Normalizes a list of exception entries into unique, non-blank strings.
    #
    # @param entries [Array<String>, String, nil] raw exception entries
    # @return [Array<String>] deduplicated, stripped, non-empty strings
    def normalize_exception_entries(entries)
      Array(entries).flatten.compact.map(&:to_s).map(&:strip).reject(&:empty?).uniq
    end

    # Extracts identifying details from a declaration item.
    #
    # @param item [Object] a declaration object (e.g., FileDeclaration, ClassDeclaration)
    # @return [Hash{Symbol => String, nil}] hash with :name, :class_name, :file_path, :line
    def item_details(item)
      {
        name: item.respond_to?(:name) ? item.name : nil,
        class_name: item.respond_to?(:class_name) ? item.class_name : nil,
        file_path: item.respond_to?(:file_path) ? item.file_path : 'Unknown file',
        line: item.respond_to?(:line) ? item.line : nil
      }
    end

    # Returns a list of unique identifier strings for an item, used for matching.
    #
    # @param item [Object] a declaration object
    # @return [Array<String>] identifiers such as name, class name, file path, and file:line
    def item_identifiers(item)
      details = item_details(item)
      identifiers = [details[:name], details[:class_name], details[:file_path]]

      if details[:line]
        identifiers << "#{details[:file_path]}:#{details[:line]}"
      end

      identifiers.compact.uniq
    end

    # Checks whether a given exception entry string matches an item.
    #
    # @param entry [String] an allowlist or baseline entry
    # @param item [Object] a declaration object
    # @return [Boolean] true if the entry matches the item by name, class, or path
    def exception_entry_matches_item?(entry, item)
      normalized_entry = entry.to_s.strip
      return false if normalized_entry.empty?

      details = item_details(item)
      return true if item_identifiers(item).include?(normalized_entry)

      file_path = details[:file_path]
      file_path && (file_path.end_with?(normalized_entry) || file_path.end_with?("/#{normalized_entry}"))
    end

    # Classifies items into violations, baseline matches, allowlist matches,
    # and detects stale entries in either list.
    #
    # @param subject_collection [Array, Object] items to classify
    # @param allowlist [Array<String>, nil] allowed exception entries
    # @param baseline [Array<String>, nil] baseline exception entries
    # @return [Hash{Symbol => Array<String>}] keys: :violations, :baseline, :allowlist,
    #   :stale_baseline, :stale_allowlist
    def classify_items(subject_collection, allowlist: nil, baseline: nil)
      items = Array(subject_collection).compact
      normalized_allowlist = normalize_exception_entries(allowlist)
      normalized_baseline = normalize_exception_entries(baseline)
      matched_baseline_entries = []
      matched_allowlist_entries = []

      grouped_items = items.group_by do |item|
        matching_baseline_entry = normalized_baseline.find do |entry|
          exception_entry_matches_item?(entry, item)
        end

        if matching_baseline_entry
          matched_baseline_entries << matching_baseline_entry
          :baseline
        else
          matching_allowlist_entry = normalized_allowlist.find do |entry|
            exception_entry_matches_item?(entry, item)
          end

          if matching_allowlist_entry
            matched_allowlist_entries << matching_allowlist_entry
            :allowlist
          else
            :violations
          end
        end
      end

      classifications = {
        baseline: Array(grouped_items[:baseline]).map { |item| element_name(item) },
        allowlist: Array(grouped_items[:allowlist]).map { |item| element_name(item) },
        violations: Array(grouped_items[:violations]).map { |item| element_name(item) }
      }

      classifications.merge(
        stale_baseline: normalized_baseline - matched_baseline_entries.uniq,
        stale_allowlist: normalized_allowlist - matched_allowlist_entries.uniq
      )
    end

    # Formats a human-readable description of an item for failure messages.
    #
    # @param item [Object] a declaration object
    # @return [String] formatted multi-line description
    def element_name(item)
      details = item_details(item)
      location = [details[:file_path], details[:line]].compact.join(':')

      case
      when details[:name] && details[:class_name]
        "  - element: #{details[:name]}\n  - class: #{details[:class_name]}\n  - file: #{location}"
      when details[:name]
        "  - element: #{details[:name]}\n  - file: #{location}"
      when details[:class_name]
        "  - class: #{details[:class_name]}\n  - file: #{location}"
      else
        "  - unknown element in #{location}"
      end
    end

    # Builds a formatted string of violations and stale entries for failure output.
    #
    # @return [String, nil] formatted sections or nil if no classified items
    def formatted_matcher_groups
      return unless defined?(@classified_items) && @classified_items

      sections = []

      if @classified_items[:violations].any?
        sections << "Violations:\n#{@classified_items[:violations].join("\n")}"
      end

      if @classified_items[:stale_baseline].any?
        stale_entries = @classified_items[:stale_baseline].map { |entry| "  - #{entry}" }
        sections << "Stale baseline entries:\n#{stale_entries.join("\n")}"
      end

      if @classified_items[:stale_allowlist].any?
        stale_entries = @classified_items[:stale_allowlist].map { |entry| "  - #{entry}" }
        sections << "Stale allowlist entries:\n#{stale_entries.join("\n")}"
      end

      sections.join("\n")
    end

    # Formats the failure message by combining the base message with
    # custom messages and classified item details (violations, stale entries).
    #
    # Works unchanged in both RSpec matchers and Minitest assertions, since it
    # only reads instance variables set by the caller (+@failure_message+,
    # +@custom_message+, +@classified_items+).
    #
    # @param base_message [String] the default failure message
    # @return [String] formatted failure message
    def message_for_failure(base_message)
      return @failure_message if @failure_message

      details = formatted_matcher_groups

      if @custom_message
        if details && !details.empty?
          "#{@custom_message}\n#{details}"
        else
          @custom_message
        end
      elsif details && !details.empty?
        "#{base_message}\n#{details}"
      else
        base_message
      end
    end
  end
end
