class Token::CreateMagicLink < ApplicationInteractor
  def call
    context.magic_link = MagicLink.create(
      email: context.email,
      expiration_offset: context.expiration_offset
    )
  end
end
