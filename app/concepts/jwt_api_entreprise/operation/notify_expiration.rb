module JwtApiEntreprise::Operation
  class NotifyExpiration < Trailblazer::Operation
    step :find_expiring_tokens
    step :send_expiration_notices


    def find_expiring_tokens(ctx, expire_in:, **)
      expiration_period = expire_in.days.from_now.to_i
      ctx[:expiring_tokens] = JwtApiEntreprise
        .where(archived: false, blacklisted: false)
        .where("exp <= ? AND NOT days_left_notification_sent::jsonb @> '?'::jsonb", expiration_period, expire_in)
    end

    def send_expiration_notices(ctx, expiring_tokens:, expire_in:, **)
      expiring_tokens.each do |jwt|
        # TODO Clean when no more JWT issued from DS
        if jwt.authorization_request_id == nil # Old JWT issued from DS
          JwtApiEntrepriseMailer.expiration_notice_old(jwt, expire_in).deliver_later
        else
          JwtApiEntrepriseMailer.expiration_notice(jwt, expire_in).deliver_later
        end
        jwt.days_left_notification_sent << expire_in
        jwt.save
      end
    end
  end
end
