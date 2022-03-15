class API::DatapassWebhooksController < APIController
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
      data: {}
    ).to_h.symbolize_keys
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
