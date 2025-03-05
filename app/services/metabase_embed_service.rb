require 'jwt'

class MetabaseEmbedService
  METABASE_SITE_URL = 'https://metabase.entreprise.api.gouv.fr'.freeze

  def initialize(resource:, params: {})
    @resource = resource
    @params = params
  end

  def url
    "#{METABASE_SITE_URL}/embed/#{kind}/#{token}#bordered=false&titled=false"
  end

  private

  def token
    payload = {
      resource: @resource,
      params: @params,
      exp: Time.now.to_i + (60 * 10)
    }

    JWT.encode(payload, metabase_secrey_key)
  end

  def kind
    if @resource.key?(:question_id) || @resource.key?(:question)
      'question'
    elsif @resource.key?(:dashboard)
      'dashboard'
    else
      raise ArgumentError, 'Invalid resource'
    end
  end

  def metabase_secrey_key
    Rails.application.credentials.metabase_secret_key
  end
end
