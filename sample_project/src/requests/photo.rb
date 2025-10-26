module Requests
  module Photo
    class Result < Base::Request
      extracts :device_id, :profile_id, :photo_id

      validates device_id: Validators::Devices::DeviceId

      validates_required :photo_id, :profile_id

      returns :profile_id
    end
  end
end