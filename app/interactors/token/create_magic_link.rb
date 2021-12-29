class Token::CreateMagicLink < ApplicationInteractor
  def call
    context.token.generate_magic_link_token
  end
end
