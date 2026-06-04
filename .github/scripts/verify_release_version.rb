#!/usr/bin/env ruby
# frozen_string_literal: true
#
# Verifies that lib/rubyzen/version.rb matches the release tag, so that a
# GitHub Release can never publish a gem whose version doesn't match the tag.

require_relative '../../lib/rubyzen/version'

tag = ENV.fetch('RELEASE_TAG', '').strip
version = Rubyzen::VERSION

if version == tag
  puts "version.rb (#{version}) matches the release tag (#{tag})"
else
  puts "::error::version.rb (#{version}) does not match the release tag (#{tag.inspect}). " \
       'Bump the lib/rubyzen/version.rb before releasing.'
  exit 1
end
