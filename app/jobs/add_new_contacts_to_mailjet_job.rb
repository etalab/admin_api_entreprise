class AddNewContactsToMailjetJob < ApplicationJob
  queue_as :default

  def perform
    ::MailjetContacts::Operation::Create.call
  end
end
