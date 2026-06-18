# frozen_string_literal: true

require_relative '../spec_helper'

RSpec.describe 'Questions should not have side effects' do
  let(:write_prefixes) { %w[create update delete destroy save] }

  let(:side_effect_call_sites) do
    questions.all_methods.call_sites.filter do |cs|
      write_call?(cs) && (constructor_receiver_repo?(cs) || local_variable_receiver_repo?(cs))
    end
  end

  def write_call?(call_site)
    write_prefixes.any? { |prefix| call_site.method_name.start_with?(prefix) }
  end

  def constructor_receiver_repo?(call_site)
    receiver = call_site.receiver_expression
    receiver&.constructor? && receiver.constant_name&.start_with?('Repos::')
  end

  def local_variable_receiver_repo?(call_site)
    receiver = call_site.receiver_expression
    return false unless receiver&.local_variable?

    repo_locals(call_site.parent).include?(receiver.name)
  end

  def repo_locals(method_declaration)
    return [] unless method_declaration

    method_declaration.assignments.filter_map do |assignment|
      value = assignment.value
      next unless value&.constructor?
      next unless value.constant_name&.start_with?('Repos::')

      assignment.name
    end
  end

  context 'given question classes' do
    it 'does not call write methods on Repos' do
      expect(side_effect_call_sites).to zen_empty
    end
  end
end
