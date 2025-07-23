class UserPresenter
  def show
    Message.where(id: 1)

    user_repo = UserRepository.new
    if user_repo.nil?
      LOGGER.info('No user repo found', details: { params: args})
    end

    user_repo.find(1)
    User.where(removed_at: nil)
    LOGGER.info('Sending an email', params: args)
  end
end
