class ApplicationMailer < ActionMailer::Base
  default from: Rails.configuration.emails_sender_address
  layout 'mailer'

  helper :friendly_date
end
