class Admin::Tokens::BanToken < ApplicationInteractor
  def call
    if token.blank?
      fail!('Token does not exist', :warning)
    elsif token.blacklisted?
      fail!('Token already blacklisted', :warning)
    else
      ban_token
    end
  end

  private

  def ban_token
    context.new_token = create_new_token if generate_new_token?
    token.update(blacklisted_at: context.blacklisted_at || 1.month.from_now)
  end

  def create_new_token
    copy = token.dup
    copy.iat = Time.zone.now.to_i
    copy.save
    copy
  end

  def generate_new_token?
    context.generate_new_token != false
  end

  def token
    context.token
  end
end
