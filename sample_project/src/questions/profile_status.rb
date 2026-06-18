module Questions
  class ProfileStatus
    # Violation: a write call on a freshly-constructed Repo (constructor receiver).
    def reset?
      Repos::Profiles.new.delete(profile_id)
    end

    # Violation: a write call via a local variable assigned a Repo
    # (assignment + local-variable receiver).
    def suspend?
      repo = Repos::Profiles.new
      repo.update(profile_id, suspended: true)
    end

    # Compliant: a read call (find) is just data retrieval.
    def active?
      Repos::Profiles.new.find(profile_id)
    end
  end
end
