require 'jwt'

class MetabaseEmbedService
  METABASE_SITE_URL = 'https://metabase.entreprise.api.gouv.fr'.freeze

  def initialize(question_id, params = {})
    @question_id = question_id
    @params = params
  end

  def url
    "#{METABASE_SITE_URL}/embed/question/#{token}#bordered=false&titled=false"
  end

  private

  def token
    payload = {
      resource: {
        question: @question_id
      },
      params: @params,
      exp: Time.now.to_i + (60 * 10)
    }

    JWT.encode(payload, metabase_secrey_key)
  end

  def metabase_secrey_key
    Rails.application.credentials.metabase_secret_key
  end
end
