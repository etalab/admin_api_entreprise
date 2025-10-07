class APIParticulier::TokenMailerPreview < ActionMailer::Preview
  %w[
    expiration_notice_90J
    expiration_notice_60J
    expiration_notice_30J
    expiration_notice_15J
    expiration_notice_7J
    expiration_notice_0J
  ].each do |method|
    send('define_method', method) do
      APIParticulier::TokenMailer.send(method, { to:, cc:, token: })
    end
  end

  def magic_link
    APIParticulier::TokenMailer.magic_link(magic_link_record, host)
  end

  def banned
    APIParticulier::TokenMailer.banned(
      token: new_token,
      old_token: banned_token,
      email: 'example@fake.com',
      comment: 'Token was compromised due to suspicious activity'
    )
  end

  private

  def to
    'example@fake.com'
  end

  def cc; end

  def token
    AuthorizationRequest.with_tokens_for('particulier').first.token
  end

  def new_token
    Token.active_for('particulier').first || token
  end

  def banned_token
    old_token = token.dup
    old_token.blacklisted_at = 1.month.from_now
    old_token
  end

  def magic_link_record
    MagicLink.first
  end

  def host
    'http://particulier.api.gouv.fr/'
  end
end
