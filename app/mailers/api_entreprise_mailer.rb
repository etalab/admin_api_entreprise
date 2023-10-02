class APIEntrepriseMailer < ApplicationMailer
  default from: 'support@entreprise.api.gouv.fr'
  default_url_options[:host] = 'https://entreprise.api.gouv.fr'
end
