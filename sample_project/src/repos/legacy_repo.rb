require 'logger'

module Repositories
  class LegacyRepo

    def photos_not_removed
      ProfilePhoto.where(removed_at: nil)
      LOGGER.info('Sending an email', details: { params: { user_id: 123 } })
    end
  end
end
