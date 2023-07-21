class ApplicationMailer < ActionMailer::Base
  layout 'mailer'

  helper :friendly_date
end
