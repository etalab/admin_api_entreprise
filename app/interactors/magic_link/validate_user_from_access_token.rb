class MagicLink::ValidateUserFromAccessToken < ApplicationInteractor
  def call
    context.magic_link = magic_link
    context.user = user

    return if valid_user_magic_link?

    context.fail!
  end

  private

  def valid_user_magic_link?
    context.magic_link && context.user && magic_link_not_expired?
  end

  def magic_link
    MagicLink.where(access_token: context.access_token).last
  end

  def user
    User.find_by(email: context.magic_link.email)
  end

  def magic_link_not_expired?
    !context.magic_link.expired?
  end
end
