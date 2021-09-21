class API::DatapassWebhooksController < APIController
  skip_before_action :jwt_authenticate!
  skip_before_action :verify_authenticity_token

  before_action :track_payload_through_sentry
  before_action :verify_hub_signature!

  def create
    result = DatapassWebhook.call(**datapass_webhook_params)

    if result.success?
      handle_success(result)
    else
      render json: {}, status: :unprocessable_entity
    end
  end

  private

  def handle_success(result)
    if event == 'validate_application'
      render json: {
        token_id: result.token_id
      }.compact
    else
      render json: {}
    end
  end

  def datapass_webhook_params
    params.permit(
      :event,
      :model_type,
      :fired_at,
      data: {},
    ).to_h.symbolize_keys
  end

  def event
    params[:event]
  end

  def track_payload_through_sentry
    Sentry.set_context(
      'DataPass webhook incoming payload',
      payload: params.permit!.to_h.except('controller', 'action', 'datapass_webhook'),
    )
    Sentry.capture_message(
      'DataPass Incoming Payload',
      {
        level: 'info',
      }
    )
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
