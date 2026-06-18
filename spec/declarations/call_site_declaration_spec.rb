require 'spec_helper'

RSpec.describe Rubyzen::Declarations::CallSiteDeclaration do
  def call_sites_from(source)
    file = parse_ruby(<<~RUBY)
      class Foo
        def bar
          #{source}
        end
      end
    RUBY
    file.classes.first.instance_methods.first.call_sites
  end

  describe '#name and #method_name' do
    it 'returns the called method name' do
      sites = call_sites_from('User.find(1)')
      site = sites.with_name('find').first
      expect(site.name).to eq('find')
      expect(site.method_name).to eq('find')
    end
  end

  describe '#receiver' do
    it 'returns the constant receiver name' do
      sites = call_sites_from('User.find(1)')
      site = sites.with_name('find').first
      expect(site.receiver).to eq('User')
    end

    it 'returns nil when receiver is not a constant' do
      sites = call_sites_from('foo.bar')
      site = sites.with_name('bar').first
      expect(site.receiver).to be_nil
    end

    it 'returns nil when there is no receiver' do
      sites = call_sites_from('puts "hello"')
      site = sites.with_name('puts').first
      expect(site.receiver).to be_nil
    end
  end

  describe '#keyword_args' do
    it 'returns keyword argument keys' do
      sites = call_sites_from('log(level: :info, details: "msg")')
      site = sites.with_name('log').first
      expect(site.keyword_args).to contain_exactly(:level, :details)
    end

    it 'returns empty array when no keyword args' do
      sites = call_sites_from('puts "hello"')
      site = sites.with_name('puts').first
      expect(site.keyword_args).to zen_empty
    end
  end

  describe '#keyword_arg_value_pairs' do
    it 'returns keyword arg to value mapping' do
      sites = call_sites_from('log(level: :info, count: 5)')
      site = sites.with_name('log').first
      pairs = site.keyword_arg_value_pairs
      expect(pairs[:level]).to eq(:info)
      expect(pairs[:count]).to eq(5)
    end
  end

  describe '#symbols' do
    it 'returns positional symbol arguments' do
      sites = call_sites_from('validates :name, :email')
      site = sites.with_name('validates').first
      expect(site.symbols).to eq([:name, :email])
    end
  end

  describe '#strings' do
    it 'returns positional string arguments' do
      sites = call_sites_from('require "json"')
      site = sites.with_name('require').first
      expect(site.strings).to eq(['json'])
    end
  end

  describe '#source_code' do
    it 'returns the source code of the call' do
      sites = call_sites_from('puts "hello"')
      site = sites.with_name('puts').first
      expect(site.source_code).to eq('puts "hello"')
    end
  end

  describe '#line' do
    it 'returns the line number' do
      sites = call_sites_from('puts "hello"')
      site = sites.with_name('puts').first
      expect(site.line).to be_a(Integer)
    end
  end

  describe '#class_name' do
    it 'returns the enclosing class name' do
      sites = call_sites_from('puts "hello"')
      site = sites.with_name('puts').first
      expect(site.class_name).to eq('Foo')
    end
  end

  describe '#receiver_expression' do
    it 'models a constructor receiver and resolves its constant' do
      site = call_sites_from('Repos::Foo.new.create(1)').with_name('create').first
      expect(site.receiver_expression.constructor?).to be(true)
      expect(site.receiver_expression.constant_name).to eq('Repos::Foo')
    end

    it 'is nil for a receiverless call' do
      site = call_sites_from('save').with_name('save').first
      expect(site.receiver_expression).to be_nil
    end
  end

  describe '#arguments' do
    it 'exposes a constant first argument' do
      site = call_sites_from('allow(Repos::Foo)').with_name('allow').first
      expect(site.arguments.first.constant_name).to eq('Repos::Foo')
    end
  end

  describe '#enclosing_blocks' do
    it 'finds an enclosing block by name' do
      sites = call_sites_from("with_admin_context do\n        get '/admin/x'\n      end")
      site = sites.with_name('get').first
      expect(site.enclosing_blocks.with_name('with_admin_context')).not_to be_empty
    end

    it 'is empty when not nested in a matching block' do
      site = call_sites_from("get '/admin/x'").with_name('get').first
      expect(site.enclosing_blocks.with_name('with_admin_context')).to be_empty
    end
  end
end
