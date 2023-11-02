class APIParticulierMailer < ApplicationMailer
  default from: 'API Particulier <support@particulier.api.gouv.fr>'

  default_url_options[:host] = Rails.env.production? ? 'https://particulier.api.gouv.fr' : "https://#{Rails.env}.particulier.api.gouv.fr"

  protected

  def extract_host
    ActionMailer::Base.default_url_options[:host] = valid_host('api_particulier')
  end
end
