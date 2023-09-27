class APIEntreprise::AuthorizationRequestMailerPreview < ActionMailer::Preview
  def embarquement_brouillon_en_attente
    APIEntreprise::AuthorizationRequestMailer.embarquement_brouillon_en_attente(to:, cc:, full_name:, authorization_request_external_id:)
  end

  private

  def to
    'example@fake.com'
  end

  def cc; end

  def full_name
    'John WICK'
  end

  def authorization_request_external_id
    '420'
  end
end
