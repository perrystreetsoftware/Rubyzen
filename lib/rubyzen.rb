# Rubyzen entry point — loads the framework-agnostic core only.
#
# `require 'rubyzen'` gives you the parsing/analysis API (Rubyzen::Project,
# declarations, collections) without any test framework attached. To write lint
# rules, require the adapter for your test framework instead:
#
#   require 'rubyzen/rspec'      # RSpec matchers:     zen_empty / zen_true / zen_false
#   require 'rubyzen/minitest'   # Minitest assertions: assert_zen_empty / _true / _false
#
# Each adapter loads this core automatically
require_relative 'rubyzen/core'
