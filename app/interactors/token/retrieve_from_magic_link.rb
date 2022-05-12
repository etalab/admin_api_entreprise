class Token::RetrieveFromMagicLink < ApplicationInteractor
  def call
    retrieve_jwt_from_magic_token
    fail!('invalid_magic_link', 'warn') if magic_link_expired?
  end

  private

  def retrieve_jwt_from_magic_token
    context.jwt = Token.find_by(magic_link_token: context.magic_token)
    fail!('invalid_magic_link', 'warn') unless context.jwt
  end

  def magic_link_expired?
    expiration_time = context.jwt.magic_link_issuance_date + 4.hours
    Time.zone.now >= expiration_time
  end
end
