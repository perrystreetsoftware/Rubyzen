require 'logger'

module Repositories
  class LegacyRepo
    ProfilePhoto.where(removed_at: nil)
    LOGGER.info('Sending an email', details: { params: args})
  end
end
