class MagicLink::DeliverEmail < ApplicationInteractor
  def call
    if context.user.present?
      deliver_magic_link_user
    elsif context.contact.present?
      deliver_magic_link_contact
    end
  end

  private

  def deliver_magic_link_user
    UserMailer.magic_link_signin(magic_link, host).deliver_later
  end

  def deliver_magic_link_contact
    TokenMailer.magic_link(magic_link, host).deliver_later
  end

  def magic_link
    context.magic_link
  end

  def host
    context.host
  end
end
