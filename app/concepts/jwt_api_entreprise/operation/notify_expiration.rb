module JwtApiEntreprise::Operation
  class NotifyExpiration < Trailblazer::Operation
    step :find_expiring_tokens
    step :send_expiration_notices


    def find_expiring_tokens(ctx, delay:, **)
      expiration_period = delay.days.from_now.to_i
      ctx[:expiring_tokens] = JwtApiEntreprise
        .where("exp <= ? AND NOT days_left_notification_sent::jsonb @> '?'::jsonb", expiration_period, delay)
    end

    def send_expiration_notices(ctx, expiring_tokens:, delay:, **)
      expiring_tokens.each do |jwt|
        JwtApiEntrepriseMailer.expiration_notice(jwt).deliver_now
        jwt.days_left_notification_sent << delay
        jwt.save
      end
    end
  end
end
