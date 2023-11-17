class APIEntreprise::TokenMailerPreview < ActionMailer::Preview
  %w[
    expiration_notice_90J
    expiration_notice_60J
    expiration_notice_30J
    expiration_notice_15J
    expiration_notice_7J
    expiration_notice_0J_expired
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
