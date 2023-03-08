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
    Token
      .joins(:authorization_request, :user)
      .left_joins(:contacts)
      .where('contacts.email = :email OR users.email = :email', email:)
  end
end
