class Admin::Tokens::BanToken < ApplicationInteractor
  def call
    if token.blank?
      fail!('Token does not exist', :warning)
    elsif token.blacklisted?
      fail!('Token already blacklisted', :warning)
    else
      token.update(blacklisted_at: context.blacklisted_at || 1.month.from_now)
    end
  end

  private

  def token
    context.token
  end
end
