require 'fileutils'

namespace :dev do
  desc 'initialize dev environment'
  task :init do
    create_secrets
  end

  def create_secrets
    puts 'create dummy admin secrets'.green
    content = secrets
    file = File.new('config/secrets.yml', 'w+')
    file.write(content.unindent)
  end

  def secrets
    <<SECRETS
    defaults: &DEFAULTS
      jwt_hash_secret: 'wowmuchsecret'
      jwt_hash_algo: 'HS256'

    development:
      secret_key_base: 1921d3b684468dbc2f881d20baa64212a3ad44af8c8de09ed5a211bd3c0b1cbad91c4ed172b2b7046dc9b69b2c83ae272588b15497f54db924d615d8a50caeb2
      <<: *DEFAULTS
    test:
      secret_key_base: b18f9271079e21fe1e109fa135b0d2de8d0495270eaff41c2ef1bb4416bfcb0b79c5bc4252b9049848a4eb49617ba1a64dd1c094c9be11442605933e0a7aad11
      <<: *DEFAULTS
SECRETS
  end
end
