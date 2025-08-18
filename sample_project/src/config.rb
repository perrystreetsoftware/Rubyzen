DATABASE_URL = "postgresql://localhost/myapp"
API_VERSION = "v1"
MAX_RETRIES = 3

class Config
  DEFAULT_TIMEOUT = 30
  
  def self.database_url
    DATABASE_URL
  end
end

module AppConstants
  LOG_LEVEL = "info"
end
