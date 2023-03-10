class MagicLink::ValidateUserFromAccessToken < ApplicationInteractor
  def call
    context.magic_link = magic_link
    context.fail! unless valid_magic_link?

    context.user = user
    context.fail! unless user
  end

  private

  def valid_magic_link?
    context.magic_link && magic_link_not_expired?
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
