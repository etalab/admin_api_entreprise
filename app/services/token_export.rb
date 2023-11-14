require 'csv'

class TokenExport
  FILEPATH = 'config/api_particulier_legacy_tokens.yml'.freeze
  DEMARCHES_BY_USER = {
    'laurent.delattre@3douest.com': ['3d-ouest'],
    'marina.morozova@abelium.fr': ['abelium'],
    'm.zniber@agoraplus.fr': ['agora-plus'],
    'pierre-arnaud.faure@aiga.fr': ['aiga'],
    'p.odille@bolbec.fr': ['docaposte-fast'],
    'technique@waigeo.fr': ['waigeo'],
    'support@cantine-de-france.fr': ['cantine-de-france'],
    'rjalabert@cirilgroup.com': ['civil-enfance-ciril-group'],
    's-guglielmone@cosoluce.fr': ['cosoluce-fluo'],
    'projet@qiis.fr': ['qiis'],
    'richard.ghesquiere@nfi.fr': ['nfi-grc'],
    'ahmed.ghoubari@jvs.fr': ['jvs-parascol'],
    'jcgeeraert@mushroom-software.com': %w[city-family-mushroom-software-cnaf city-family-mushroom-software-dgfip city-family-mushroom-software],
    'n.ronvel@arpege.fr': %w[arpege-concerto ccas-arpege]
  }.freeze

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
    tokens = []
    if user_demarche.present?
      user_demarche.each do |demarche|
        tokens.concat(tokens_to_export_for_demarche(demarche))
      end
    end

    tokens.concat(tokens_for_contact_technique)
  end

  def user_demarche
    DEMARCHES_BY_USER[@user.email.to_sym]
  end

  def tokens_for_contact_technique
    tokens = Token
      .includes(:authorization_request)
      .where("extra_info->'legacy_token_id' IS NOT NULL")
      .where(authorization_request: { status: 'validated', demarche: nil })

    tokens.filter do |token|
      token.authorization_request.contact_technique.present? && token.authorization_request.contact_technique.email == @user.email
    end
  end

  def tokens_to_export_for_demarche(demarche)
    Token
      .includes(:authorization_request)
      .where("extra_info->'legacy_token_id' IS NOT NULL")
      .where(authorization_request: { status: 'validated', demarche: })
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
