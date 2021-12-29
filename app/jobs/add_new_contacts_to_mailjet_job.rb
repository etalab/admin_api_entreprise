class AddNewContactsToMailjetJob < ApplicationJob
  queue_as :default

  def perform
    ::Mailjet::CreateContacts.call
  end
end
