module Rubyzen
  module Matchers
    module MatcherHelpers
      def normalize_exception_entries(entries)
        Array(entries).flatten.compact.map(&:to_s).map(&:strip).reject(&:empty?).uniq
      end

      def item_details(item)
        {
          name: item.respond_to?(:name) ? item.name : nil,
          class_name: item.respond_to?(:class_name) ? item.class_name : nil,
          file_path: item.respond_to?(:file_path) ? item.file_path : 'Unknown file',
          line: item.respond_to?(:line) ? item.line : nil
        }
      end

      def item_identifiers(item)
        details = item_details(item)
        identifiers = [details[:name], details[:class_name], details[:file_path]]

        identifiers << "#{details[:file_path]}:#{details[:line]}" if details[:line]

        identifiers.compact.uniq
      end

      def exception_entry_matches_item?(entry, item)
        normalized_entry = entry.to_s.strip
        return false if normalized_entry.empty?

        details = item_details(item)
        return true if item_identifiers(item).include?(normalized_entry)

        file_path = details[:file_path]
        file_path && (file_path.end_with?(normalized_entry) || file_path.end_with?("/#{normalized_entry}"))
      end

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

      def element_name(item)
        details = item_details(item)
        location = [details[:file_path], details[:line]].compact.join(':')

        if details[:name] && details[:class_name]
          "  - element: #{details[:name]}\n  - class: #{details[:class_name]}\n  - file: #{location}"
        elsif details[:name]
          "  - element: #{details[:name]}\n  - file: #{location}"
        elsif details[:class_name]
          "  - class: #{details[:class_name]}\n  - file: #{location}"
        else
          "  - unknown element in #{location}"
        end
      end

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

      def self.included(base)
        base.define_method(:message_for_failure) do |base_message|
          details = formatted_matcher_groups

          if @custom_message
            if details && !details.empty?
              "#{@custom_message}\n#{details}"
            elsif defined?(@offenders) && @offenders.any?
              "#{@custom_message}\nViolations: #{@offenders.join(', ')}"
            else
              @custom_message
            end
          elsif @failure_message
            @failure_message
          elsif details && !details.empty?
            "#{base_message}\n#{details}"
          else
            base_message
          end
        end
      end
    end
  end
end
