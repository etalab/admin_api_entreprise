class Token::SendEmailWithMagicLink < ApplicationInteractor
  def call
    TokenMailer.magic_link(context.magic_link, context.host).deliver_later
  end
end
