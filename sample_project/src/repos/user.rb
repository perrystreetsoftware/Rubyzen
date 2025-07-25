module Repos
  class User
    def method
      ProfilePhoto.where(removed_at: nil) if true
      LOGGER.info('Sending an email', details: { params: args})
    end
  end
end