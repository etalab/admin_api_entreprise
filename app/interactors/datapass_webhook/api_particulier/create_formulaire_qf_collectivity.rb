class DatapassWebhook::APIParticulier::CreateFormulaireQFCollectivity < ApplicationInteractor
  delegate :authorization_request, to: :context
  delegate :organization, to: :authorization_request, private: true

  def call
    FormulaireQFAPIClient.new.create_collectivity(organization:, editor_id:)
  end

  private

  def editor_id
    authorization_request.extra_infos.dig('service_provider', 'id')
  end
end
