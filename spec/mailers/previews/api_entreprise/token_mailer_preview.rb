class APIEntreprise::TokenMailerPreview < ActionMailer::Preview
  %w[
    expiration_notice_J-90
    expiration_notice_J-60
    expiration_notice_J-30
    expiration_notice_J-15
    expiration_notice_J-7
    expiration_notice_J-0_expired
  ].each do |method|
    send('define_method', method) do
      APIEntreprise::TokenMailer.send(method, { to:, cc:, authorization_request: })
    end
  end

  def magic_link
    APIEntreprise::TokenMailer.magic_link(magic_link_record, host)
  end

  private

  def to
    'example@fake.com'
  end

  def cc; end

  def authorization_request
    AuthorizationRequest.with_tokens_for('entreprise').first
  end

  def magic_link_record
    MagicLink.first
  end

  def host
    'http://entreprise.api.gouv.fr/'
  end
end
