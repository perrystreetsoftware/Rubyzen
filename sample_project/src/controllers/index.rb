# frozen_string_literal: true

module Controllers
  class Index
    request Test
    service Test

    def should_enqueue?
      true
    end

    def some_other_method
      if rand > 0.5
        puts "Condition met"
      else
        puts "Condition not met"
      end
    end

    def self.some_class_method
    end
  end
end
