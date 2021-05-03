class AddNewContactsToMailjetJob < ApplicationJob
  queue_as :default

  def perform
    ::MailjetContact::Operation::Create.call
  end
end
