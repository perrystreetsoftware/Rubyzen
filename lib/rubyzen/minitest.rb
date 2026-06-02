# Minitest entry point for Rubyzen.
#
# Loads the framework-agnostic core plus the Minitest assertions.
# Require it from your test/test_helper.rb:
#
#   # Gemfile
#   group :test do
#     gem 'rubyzen-lint'
#     gem 'minitest'
#   end
#
#   # test/test_helper.rb
#   require 'rubyzen/minitest'
#
# The assertions (+assert_zen_empty+, +assert_zen_true+, +assert_zen_false+) are
# mixed into +Minitest::Assertions+, so they are available in every Minitest test
# class and spec-style block automatically.
require_relative 'core'
require 'minitest'
require_relative 'assertions/zen_assertions'

# Call +include+ via +send+ so YARD's static parser doesn't try to document a
# mixin into the external Minitest::Assertions namespace (the constant only
# exists at runtime, after +require 'minitest'+, so YARD would warn). +include+
# is public on Module, so this is behaviourally identical to a plain call.
Minitest::Assertions.send(:include, Rubyzen::Assertions)
