class ScheduleExpirationNoticeEmailJob < ApplicationJob
  include FriendlyDateHelper

  attr_reader :token_id, :expires_in

  queue_as :default

  def perform(token_id, expires_in)
    @token_id = token_id
    @expires_in = expires_in

    return if token.nil? || token.authorization_request.nil?

    return unless APIEntreprise::TokenMailer.respond_to?(template)

    APIEntreprise::TokenMailer.send(template, token).deliver_later
  end

  private

  def token
    @token ||= Token.find_by(id: @token_id)
  end

  def template
    "expiration_notice_#{@expires_in}J".to_sym
  end
end
