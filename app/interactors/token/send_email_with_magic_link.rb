class Token::SendEmailWithMagicLink < ApplicationInteractor
  def call
    TokenMailer.magic_link(context.email, context.token).deliver_later
  end
end
