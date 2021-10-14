module JwtAPIEntreprise::Operation
  class NotifyExpiration < Trailblazer::Operation
    step :find_expiring_tokens
    step :send_expiration_notices


    def find_expiring_tokens(ctx, expire_in:, **)
      expiration_period = expire_in.days.from_now.to_i
      ctx[:expiring_tokens] = JwtAPIEntreprise
        .not_blacklisted
        .where(archived: false)
        .where("exp <= ? AND NOT days_left_notification_sent::jsonb @> '?'::jsonb", expiration_period, expire_in)
    end

    def send_expiration_notices(ctx, expiring_tokens:, expire_in:, **)
      expiring_tokens.each do |jwt|
        ScheduleExpirationNoticeMailjetEmailJob.perform_later(jwt, expire_in)

        jwt.days_left_notification_sent << expire_in
        jwt.save
      end
    end
  end
end
