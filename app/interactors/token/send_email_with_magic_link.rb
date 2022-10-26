class Token::SendEmailWithMagicLink < ApplicationInteractor
  def call
    TokenMailer.magic_link(context.magic_link).deliver_later
  end
end
