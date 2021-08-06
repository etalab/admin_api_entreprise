require 'openssl'

class HubSignature
  attr_reader :value, :body

  def initialize(value, body)
    @value = value
    @body = body
  end

  def valid?
    value.present? &&
      Rack::Utils.secure_compare(value, compute_signature)
  end

  def compute_signature
    "sha256=#{OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), verify_token, body)}"
  end

  private

  def verify_token
    Rails.application.credentials.webhook_verify_token!
  end
end
