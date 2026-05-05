require 'spec_helper'

RSpec.describe 'RSpec expect override' do
  it 'raises ArgumentError for non-collection subjects when loaded' do
    script = <<~'SCRIPT'
      require "rspec"
      require "rubyzen"
      require "rubyzen/rspec/rspec_config"
      include RSpec::Matchers
      begin
        expect("not a collection").to eq("not a collection")
        puts "NO_ERROR"
      rescue ArgumentError => e
        puts "RAISED: #{e.message}"
      end
    SCRIPT

    result = `RUBYZEN_PROJECT_PATHS=/tmp bundle exec ruby -I lib -e '#{script.gsub("'", "'\\\\''")}' 2>&1`
    expect(result).to include('RAISED:')
    expect(result).to include('Invalid subject')
  end

  it 'allows Rubyzen collection subjects when loaded' do
    script = <<~'SCRIPT'
      require "rspec"
      require "rubyzen"
      require "rubyzen/rspec/rspec_config"
      include RSpec::Matchers
      begin
        collection = Rubyzen::Collections::ClassesCollection.new
        expect(collection).to be_empty
        puts "OK"
      rescue => e
        puts "ERROR: #{e.message}"
      end
    SCRIPT

    result = `RUBYZEN_PROJECT_PATHS=/tmp bundle exec ruby -I lib -e '#{script.gsub("'", "'\\\\''")}' 2>&1`
    expect(result).to include('OK')
  end
end
