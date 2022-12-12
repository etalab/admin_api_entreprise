class MagicLink::ExtractUserOrContact < ApplicationInteractor
  def call
    context.user = user
    return if user

    context.contact = contact
    return if contact

    context.fail!
  end

  private

  def user
    @user ||= User.find_by(email:)
  end

  def contact
    @contact ||= Contact.find_by(email:)
  end

  def email
    context.email
  end
end
