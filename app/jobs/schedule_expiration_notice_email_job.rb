class ScheduleExpirationNoticeEmailJob < ApplicationJob
  include FriendlyDateHelper

  queue_as :default

  def perform(token_id, expires_in)
    return if expiration_in_to_template(expires_in).nil?

    token = Token.find_by(id: token_id)
    return if token.nil? || token.authorization_request.nil?

    APIEntreprise::TokenMailer.send(expiration_in_to_template(expires_in), token).deliver_later
  end

  private

  def token
    @token ||= Token.find_by(id: token_id)
  end

  def expiration_in_to_template(expires_in)
    {
      90 => :expiration_notice_90J,
      60 => :expiration_notice_60J,
      30 => :expiration_notice_30J,
      15 => :expiration_notice_15J,
      7 => :expiration_notice_7J,
      0 => :expiration_notice_0J_expired
    }[expires_in]
  end
end
