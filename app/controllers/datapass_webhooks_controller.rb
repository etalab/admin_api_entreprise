class DatapassWebhooksController < ApplicationController
  skip_before_action :jwt_authenticate!
  before_action :verify_hub_signature!

  def create
    result = DatapassWebhook.call(**datapass_webhook_params)

    if event == 'validate_application'
      render json: {
        token_id: result.token_id
      }
    else
      render json: {}
    end
  end

  private

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

  def verify_hub_signature!
    if hub_signature_invalid?
      unauthorized
    end
  end

  def hub_signature_invalid?
    !HubSignature.new(hub_signature, request.raw_post).valid?
  end

  def hub_signature
    request.headers['X-Hub-Signature-256']
  end
end
