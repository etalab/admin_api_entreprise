class Token::NotifyExpiration < ApplicationInteractor
  def call
    find_expiring_tokens
    send_expiration_notices
  end

  private

  def find_expiring_tokens
    expiration_period = expire_in.days.from_now.to_i
    context.expiring_tokens = JwtAPIEntreprise
      .not_blacklisted
      .where(archived: false)
      .where("exp <= ? AND NOT days_left_notification_sent::jsonb @> '?'::jsonb", expiration_period, expire_in)
  end

  def send_expiration_notices
    context.expiring_tokens.each do |jwt|
      ScheduleExpirationNoticeMailjetEmailJob.perform_later(jwt, expire_in)

      jwt.days_left_notification_sent << expire_in
      jwt.save
    end
  end

  def expire_in
    context.expire_in
  end
end
