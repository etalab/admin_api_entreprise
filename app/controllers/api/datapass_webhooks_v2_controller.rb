class API::DatapassWebhooksV2Controller < APIController
  include DatapassWebhooks

  protected

  def datapass_webhook_params
    params.permit(
      :event,
      :model_type,
      :model_id,
      :fired_at,
      data: {}
    ).to_h.symbolize_keys
  end

  def datapass_id
    params[:model_id]
  end

  def extract_organizer(kind)
    DatapassWebhook::V2.const_get(kind.classify)
  end
end
