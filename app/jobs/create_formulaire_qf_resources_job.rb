class CreateFormulaireQFResourcesJob < ApplicationJob
  def perform(authorization_request_id)
    authorization_request = AuthorizationRequest.find(authorization_request_id)

    DatapassWebhook::CreateFormulaireQFResources.call(authorization_request:)
  end
end
