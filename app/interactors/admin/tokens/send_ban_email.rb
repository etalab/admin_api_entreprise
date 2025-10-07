class Admin::Tokens::SendBanEmail < ApplicationInteractor
  def call
    emails.each do |email|
      mailer.with(
        token: context.new_token,
        old_token: token,
        email:,
        comment: context.comment
      ).banned.deliver_later
    end
  end

  private

  def emails
    emails = []
    emails << authorization_request.demandeur&.email
    emails << authorization_request.contact_technique&.email
    emails.compact.uniq
  end

  def token = context.token
  def authorization_request = token.authorization_request

  def mailer
    namespace.constantize::TokenMailer
  end

  def namespace
    "api_#{context.namespace}".camelize
  end
end
