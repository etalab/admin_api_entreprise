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
    args.extras do |token_id|
      token = Token.find(token_id)

      unless token.legacy_token?
        puts 'Token is not a legacy token, cannot mark as migrated'
        continue
      end

      if token.legacy_token_migrated?
        puts 'Token already migrated'
        continue
      end

      token.extra_info['legacy_token_migrated'] = 't'

      token.save!
    end
  end
end
