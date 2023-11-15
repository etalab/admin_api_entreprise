require 'csv'

class TokenExport
  FILEPATH = 'config/api_particulier_legacy_tokens.yml'.freeze

  def initialize(user)
    @user = user
  end

  def perform
    CSV.generate(headers: true, force_quotes: true) do |csv|
      csv << headers
      tokens_to_export.each do |token|
        csv << token_payload(token)
      end
    end
  end

  def tokens_to_export?
    tokens_to_export.present?
  end

  private

  def headers
    %w[
      siret
      intitule
      demandeur
      datapass_id
      nouveau_token
      ancien_token
      demarche
    ]
  end

  def tokens_to_export
    Token
      .includes(:authorization_request)
      .where('extra_info @> ?', { emails: [@user.email.downcase] }.to_json)
      .where(authorization_request: { status: 'validated' })
  end

  def token_payload(token)
    [
      token.authorization_request.siret,
      token.intitule,
      token.authorization_request.demandeur.present? ? token.authorization_request.demandeur.email : nil,
      token.authorization_request.external_id,
      token.rehash,
      legacy_token(token),
      token.authorization_request.demarche
    ]
  end

  def legacy_token(token)
    legacy_tokens.each_pair do |legacy_token, params|
      return legacy_token if params['token_id'] == token.id && params['legacy_token_id'] == token.extra_info['legacy_token_id']
    end

    nil
  end

  def legacy_tokens
    @legacy_tokens ||= YAML.load_file(
      Rails.root.join(FILEPATH)
    )
  end
end
