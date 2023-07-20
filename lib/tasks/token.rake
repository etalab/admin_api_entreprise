namespace :token do
  desc "Blacklist a token (and create a new one) token:blacklist\\['UUID'\\]"

  task :blacklist, [:token_id] => :environment do |_, args|
    token = Token.find(args.token_id)

    if token.blacklisted?
      puts 'Token already blacklisted'
      fail
    end

    copy = token.dup
    copy.iat = Time.zone.now.to_i
    copy.save

    token.update(blacklisted: true)
  end
end
