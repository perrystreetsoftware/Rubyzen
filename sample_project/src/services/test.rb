module Services
  class Test
    def results
      Services::Other.new.results

      Adapters::Infra::Relay.deliver(
        target_id: profile.id,
        message_class: SOCKET_MESSAGE_CLASS_AGE_VERIFICATION_RESULT,
        results:,
        request_guid:,
      )

      Adapters::Infra::Relay.deliver(
        target_id: profile.id,
        message_class: SOCKET_MESSAGE_CLASS_AGE_VERIFICATION_RESULT,
        results:,
        request_guid:,
      )
    end
  end
end
