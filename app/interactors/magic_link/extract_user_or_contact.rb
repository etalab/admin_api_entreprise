class MagicLink::ExtractUserOrContact < ApplicationInteractor
  def call
    context.user = user
    context.contact = contact

    context.fail! unless user || contact
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
