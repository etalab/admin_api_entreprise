require 'csv'

class TokenExport
  DIR = './token_export'.freeze

  def initialize(filepath)
    @filepath = filepath
  end

  def perform
    FileUtils.mkdir_p(DIR)

    @legacy_tokens = load_legacy_tokens
    files_to_export = {}
    tokens_to_export.find_each do |token|
      export_filename = export_filename(token)
      files_to_export[export_filename] ||= []
      files_to_export[export_filename] << token_payload(token)
    end

    files_to_export.each_pair do |export_filename, tokens|
      write_file(export_filename, tokens)
    end
  end

  private

  def tokens_to_export
    Token
      .includes(:authorization_request)
      .where("extra_info->'legacy_token_id' IS NOT NULL")
      .where(authorization_request: { status: 'validated' })
  end

  def write_file(filename, tokens)
    file = Rails.root.join("#{DIR}/#{filename}.csv")

    headers = %w[
      siret
      intitule
      demandeur
      datapass_id
      nouveau_token
      ancien_token
    ]

    CSV.open(file, 'w', write_headers: true, headers:, force_quotes: true) do |writer|
      tokens.each do |token|
        writer << token
      end
    end
  end

  def export_filename(token)
    if token.authorization_request.demarche.present?
      "demarche_#{token.authorization_request.demarche}"
    elsif !token.authorization_request.contact_technique.nil?
      "contact_technique_#{token.authorization_request.contact_technique.email}"
    else
      "demandeur_#{token.authorization_request.demandeur.email}"
    end
  end

  def tokens
    Token.includes(:authorization_request)
  end

  def token_payload(token)
    [
      token.authorization_request.siret,
      token.intitule,
      token.authorization_request.demandeur.email,
      token.authorization_request.external_id,
      token.rehash,
      legacy_token(token)
    ]
  end

  def legacy_token(token)
    @legacy_tokens.each_pair do |legacy_token, params|
      return legacy_token if params['token_id'] == token.id && params['legacy_token_id'] == token.extra_info['legacy_token_id']
    end

    nil
  end

  def load_legacy_tokens
    YAML.load_file(
      Rails.root.join(@filepath)
    )
  end
end
