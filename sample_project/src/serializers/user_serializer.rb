module Serializers
  class UserSerializer
    # Violation: a *_data method whose final expression is a raw Hash literal.
    def user_data
      log
      { id: 1, name: 'Sample' }
    end

    # Compliant: returns a Data object, not a Hash literal.
    def user_dto
      UserData.new(id: 1)
    end
  end
end
