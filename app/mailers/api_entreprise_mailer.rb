class APIEntrepriseMailer < ApplicationMailer
  default from: 'support@entreprise.api.gouv.fr'

  default_url_options[:host] = Rails.env.production? ? 'https://entreprise.api.gouv.fr' : "https://#{Rails.env}.entreprise.api.gouv.fr"
end
