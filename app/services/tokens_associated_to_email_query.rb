class TokensAssociatedToEmailQuery
  attr_reader :email, :api

  def initialize(email:, api: nil)
    @email = email
    @api = api
  end

  def call
    return tokens.active_for(api).uniq if api

    tokens.uniq
  end

  private

  def tokens
    Token.joins(:users).where(users: { email: })
  end
end
