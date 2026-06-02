# RSpec entry point for Rubyzen.
#
# Loads the framework-agnostic core plus the RSpec matchers. 
# Require it from your spec/spec_helper.rb:
#
#   # Gemfile
#   group :test do
#     gem 'rubyzen-lint'
#     gem 'rspec' # or rspec-rails
#   end
#
#   # spec/spec_helper.rb
#   require 'rubyzen/rspec'
#
# Every RSpec project should already have the `rspec` gem.
# If it is missing we raise an error.
require_relative 'core'

begin
  require 'rspec'
rescue LoadError
  raise LoadError, "Rubyzen's RSpec matchers require the 'rspec' gem. " \
                   "Add `gem 'rspec'` to your Gemfile, or use the Minitest matchers via `require 'rubyzen/minitest'`."
end

require_relative 'expectation_helpers'
require_relative 'matchers/zen_empty_matcher'
require_relative 'matchers/zen_true_matcher'
require_relative 'matchers/zen_false_matcher'
