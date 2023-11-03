class APIEntrepriseMailer < ApplicationMailer
  default from: 'API Entreprise <support@entreprise.api.gouv.fr>'

  protected

  def attach_logos
    attach_logos_for('api_entreprise')
  end

  def extract_host
    ActionMailer::Base.default_url_options[:host] = valid_host('api_entreprise')
  end
end
