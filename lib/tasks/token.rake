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

    token.update(blacklisted_at: 1.month.from_now)
  end

  desc 'Mark an API Particulier tokens (which has a legacy id) as migration token:mark_as_migrated\\[UUID1. UUID2, ...\\]'
  task :mark_as_migrated, [] => :environment do |_, args|
    MigrateLegacyTokenService.new(Token.where(id: args.extras)).perform
  end
end
