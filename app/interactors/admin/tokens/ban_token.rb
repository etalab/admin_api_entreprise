class Admin::Tokens::BanToken < ApplicationInteractor
  def call
    if token.blank?
      fail!('Token does not exist', :warning)
    elsif token.blacklisted?
      fail!('Token already blacklisted', :warning)
    else
      copy_token
    end
  end

  private

  def copy_token
    copy = token.dup
    copy.iat = Time.zone.now.to_i
    copy.save

    token.update(blacklisted_at: 1.month.from_now)
    context.new_token = copy
  end

  def token
    context.token
  end
end
