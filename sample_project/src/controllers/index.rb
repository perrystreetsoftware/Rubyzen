# frozen_string_literal: true

module Controllers
  class Index
    request Test
    service Test

    def should_enqueue?
      LOGGER.info 'test'
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

    def runtime_error_example
      do_something
    rescue RuntimeError
      handle_error
    end

    def standard_error_example
      do_something
    rescue
      handle_error
    end
  end
end
