class ScheduleExpirationNoticeEmailJob < ApplicationJob
  include FriendlyDateHelper

  attr_reader :token_id, :expires_in

  queue_as :default

  def perform(token_id, expires_in)
    @token_id = token_id
    @expires_in = expires_in

    return if token.nil? || token.authorization_request.nil?

    return unless mailer_klass.respond_to?(template)

    mailer_klass.send(template, { token: }).deliver_later
  end

  private

  def mailer_klass
    "API#{api.capitalize}::TokenMailer".constantize
  end

  def api
    token.api
  end

  def token
    @token ||= Token.find_by(id: @token_id)
  end

  def template
    "expiration_notice_#{@expires_in}J".to_sym
  end
end
