class TokensAssociatedToEmailQuery
  attr_reader :email, :api

  def initialize(email:, api: nil)
    @email = email
    @api = api
  end

  def call
    if api
      tokens.active_for(api)
    else
      tokens
    end
  end

  private

  def tokens
    Token.distinct.joins(:users).where(users: { email: })
  end
end
