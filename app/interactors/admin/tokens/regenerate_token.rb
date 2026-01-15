class Admin::Tokens::RegenerateToken < ApplicationInteractor
  def call
    return context.skip! unless generate_new_token?

    context.new_token = create_new_token
  end

  def generate_new_token?
    context.generate_new_token != false
  end

  private

  def create_new_token
    copy = token.dup
    copy.iat = Time.zone.now.to_i
    copy.save
    copy
  end

  def token
    context.token
  end
end
