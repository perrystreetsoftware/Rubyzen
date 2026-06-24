require 'spec_helper'

RSpec.describe Rubyzen::Collections::ArgumentsCollection do
  def arguments_of(source, name)
    parse_ruby("#{source}\nsentinel = 1").call_sites.with_name(name).first.arguments
  end

  it 'is the type returned by CallSiteDeclaration#arguments' do
    expect(arguments_of('build(Repos::Foo)', 'build')).to be_a(described_class)
  end

  it 'is a specialization of ExpressionsCollection (drop-in, non-breaking)' do
    expect(arguments_of('build(Repos::Foo)', 'build'))
      .to be_a(Rubyzen::Collections::ExpressionsCollection)
  end

  it 'inherits the value-expression filters' do
    args = arguments_of('build(Repos::Foo, { id: 1 })', 'build')
    expect(args.constants.map(&:constant_name)).to eq(['Repos::Foo'])
    expect(args.hash_literals).not_to be_empty
  end

  it 'stays an ArgumentsCollection after filtering' do
    args = arguments_of('build(Repos::Foo, other)', 'build')
    expect(args.constants).to be_a(described_class)
  end
end
