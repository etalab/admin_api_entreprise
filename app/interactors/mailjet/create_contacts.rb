class Mailjet::CreateContacts < ApplicationInteractor
  def call
    retrieve_users_email_attributes
    create_to_mailjet
  end

  private

  def retrieve_users_email_attributes
    context.payload = ::User.added_since_yesterday.includes(:contacts).find_each.map do |user|
      {
        email:      user.email,
        properties: ::Mailjet::ContactPropertiesAdapter.new(user).call
      }
    end

    fail!('empty_user_list', 'warn') if context.payload.empty?
  end

  def create_to_mailjet
    Mailjet::Contactslist_managemanycontacts.create(
      id:       ::Rails.application.credentials.mj_list_id!,
      action:   'addnoforce',
      contacts: context.payload
    )
  end
end
