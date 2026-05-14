# frozen_string_literal: true

require_relative '../spec_helper'

RSpec.describe 'Make sure to include remote_addr: as a param to Relay.deliver' do
  context "given a service" do
    let(:target_call_sites) do
      (jobs + services).all_methods.call_sites
    end

    context 'that calls Adapters::Infra::Relay.deliver' do
      let(:deliver_call_sites) do
        target_call_sites
          .with_receiver('Adapters::Infra::Relay')
          .with_method_name('deliver')
      end

      it "includes a remote_addr if it has a request_guid when delivering" do
        expect(deliver_call_sites.filter do |site|
          !site.keyword_args.include?(:remote_addr) &&
            site.keyword_args.include?(:request_guid)
        end).to zen_empty
      end
    end
  end
end
