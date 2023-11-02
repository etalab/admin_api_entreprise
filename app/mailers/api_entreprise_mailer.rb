class APIEntrepriseMailer < ApplicationMailer
  default from: 'API Entreprise <support@entreprise.api.gouv.fr>'

  default_url_options[:host] = Rails.env.production? ? 'https://entreprise.api.gouv.fr' : "https://#{Rails.env}.entreprise.api.gouv.fr"

  protected

  def attach_logos
    attachments.inline['logo-api.png'] = File.read(Rails.root.join('app/assets/images/mailers/api_entreprise/header-logo-api.png'))
    attachments.inline['logo-dinum.png'] = File.read(Rails.root.join('app/assets/images/mailers/header-logo-dinum.png'))
  end
end
