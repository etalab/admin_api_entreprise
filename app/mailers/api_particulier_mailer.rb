class APIParticulierMailer < ApplicationMailer
  default from: 'support@particulier.api.gouv.fr'
  default_url_options[:host] = 'https://particulier.api.gouv.fr'
end
