class APIParticulierMailer < ApplicationMailer
  default from: 'API Particulier <support@particulier.api.gouv.fr>'

  default_url_options[:host] = Rails.env.production? ? 'https://particulier.api.gouv.fr' : "https://#{Rails.env}.particulier.api.gouv.fr"
end
