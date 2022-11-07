class Token::CreateMagicLink < ApplicationInteractor
  def call
    context.magic_link = MagicLink.create(
      email: context.email,
      token_id: context.token_id,
      expires_at:
    )
  end

  private

  def expires_at
    context.expires_at || MagicLink::DEFAULT_EXPIRATION_DELAY.from_now
  end
end
