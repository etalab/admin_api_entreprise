class CreateFormulaireQFCollectivityJob < ApplicationJob
  def perform(authorization_request_id)
    authorization_request = AuthorizationRequest.find(authorization_request_id)
    FormulaireQFAPIClient.new.create_collectivity(authorization_request)
  end
end
