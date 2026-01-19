class AdminAPIToken
  def self.for(_api)
    ENV.fetch('ADMIN_API_TOKEN', nil)
  end
end
