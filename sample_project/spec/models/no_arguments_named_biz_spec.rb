require_relative '../spec_helper'

RSpec.describe 'No complex logic in models' do
  it 'has no methods with arguments named biz' do
    expect(models.all_methods.parameters.with_name(:biz).empty?).to be true
  end

  it 'has no methods with arguments named biz that have a default value' do
    expect(models.all_methods.parameters.with_name(:biz).first.default_value.empty?).to be true
  end
end
