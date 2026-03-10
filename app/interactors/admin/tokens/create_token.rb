class Admin::Tokens::CreateToken < ApplicationInteractor
  def call
    context.token = authorization_request.tokens.create!(
      Token.default_create_params.merge(
        exp: context.exp,
        scopes: authorization_request.scopes
      )
    )
  end

  private

  def authorization_request
    context.authorization_request
  end
end
