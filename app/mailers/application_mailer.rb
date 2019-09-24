class ApplicationMailer < ActionMailer::Base
  default from: Rails.configuration.emails_from_address
  layout 'mailer'
end
