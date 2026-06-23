module Questions
  class ProfileStatus
    def reset?
      Repos::Profiles.new.delete(profile_id)
    end

    def suspend?
      repo = Repos::Profiles.new
      repo.update(profile_id, suspended: true)
    end

    def active?
      Repos::Profiles.new.find(profile_id)
    end
  end
end
