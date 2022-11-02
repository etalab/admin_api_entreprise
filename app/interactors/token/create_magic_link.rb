class Token::CreateMagicLink < ApplicationInteractor
  def call
    context.magic_link = MagicLink.create(
      email: context.email,
      expires_at: context.expires_at || 4.hours.from_now
    )
  end
end
