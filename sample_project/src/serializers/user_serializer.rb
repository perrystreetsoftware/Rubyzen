module Serializers
  class UserSerializer
    def user_data
      log
      { id: 1, name: 'Sample' }
    end

    def user_dto
      UserData.new(id: 1)
    end
  end
end
