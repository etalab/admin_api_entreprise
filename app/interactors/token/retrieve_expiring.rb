class Token::RetrieveExpiring < ApplicationInteractor
  def call
    expiration_period = expire_in.days.from_now.to_i

    context.expiring_tokens = Token
      .not_blacklisted
      .where(archived: false)
      .joins(:authorization_request).where(authorization_request: { api: 'entreprise' })
      .where("exp <= ? AND NOT days_left_notification_sent::jsonb @> '?'::jsonb", expiration_period, expire_in)
  end

  private

  def expire_in
    context.expire_in
  end
end
