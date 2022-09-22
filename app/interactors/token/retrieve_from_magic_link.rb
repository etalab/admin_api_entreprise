class Token::RetrieveFromMagicLink < ApplicationInteractor
  def call
    retrieve_token_from_magic_token
    fail!('invalid_magic_link', 'warn') if magic_link_expired?
  end

  private

  def retrieve_token_from_magic_token
    context.token = Token.find_by(magic_link_token: context.magic_token)
    fail!('invalid_magic_link', 'warn') unless context.token
  end

  def magic_link_expired?
    expiration_time = context.token.magic_link_issuance_date + expiration_offset
    Time.zone.now >= expiration_time
  end

  def expiration_offset
    context.expiration_offset || 4.hours
  end
end
