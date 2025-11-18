module DatapassWebhooks
  extend ActiveSupport::Concern

  included do
    before_action :track_payload_through_sentry
    before_action :verify_hub_signature!
  end

  def api_entreprise
    handle_api('api_entreprise')
  end

  def api_particulier
    handle_api('api_particulier')
  end

  protected

  def datapass_webhook_params
    fail NotImplementedError
  end

  def datapass_id
    fail NotImplementedError
  end

  def extract_organizer(kind)
    fail NotImplementedError
  end

  private

  def handle_api(kind)
    result = extract_organizer(kind).call(**datapass_webhook_params)

    if result.success?
      handle_success(result)
    else
      render json: {}, status: :unprocessable_content
    end
  end

  def handle_success(result)
    if event == 'approve'
      render json: {
        token_id: result.token_id
      }.compact
    else
      render json: {}
    end
  end

  def track_payload_through_sentry
    Sentry.set_context(
      'DataPass webhook incoming payload',
      payload: {
        datapass_id:,
        event:
      }
    )
    Sentry.capture_message(
      'DataPass Incoming Payload',
      level: 'info'
    )
  end

  def event
    params[:event]
  end

  def verify_hub_signature!
    unauthorized unless hub_signature_valid?
  end

  def hub_signature_valid?
    HubSignature.new(hub_signature, request.raw_post).valid?
  end

  def hub_signature
    request.headers['X-Hub-Signature-256']
  end
end
