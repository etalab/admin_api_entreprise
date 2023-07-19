class ApplicationMailer < ActionMailer::Base
  default from: 'support@entreprise.api.gouv.fr'

  layout 'mailer'

  helper :friendly_date
end
