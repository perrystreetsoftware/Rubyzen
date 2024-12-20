class UserPresenter
  def show
    user_repo = UserRepository.new
    user_repo.find(1)
    User.where(removed_at: nil)
    LOGGER.info('Sending an email', params: args)
  end
end
