class Token::SendEmailWithMagicLink < ApplicationInteractor
  def call
    JwtAPIEntrepriseMailer.magic_link(context.email, context.token).deliver_later
  end
end
