module Requests
  module AgeVerification
    class Result < Base::Request
      extracts :device_id, :profile_id, :session_id

      validates device_id: Validators::Devices::DeviceId,
                profile_id: Validators::Profiles::Id

      validates_required :session_id

      returns :profile_id, :session_id
    end
  end
end