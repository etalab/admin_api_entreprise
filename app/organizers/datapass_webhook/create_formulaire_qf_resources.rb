class DatapassWebhook::CreateFormulaireQFResources < ApplicationOrganizer
  organize DatapassWebhook::APIParticulier::CreateHubEEOrganization,
    DatapassWebhook::APIParticulier::CreateHubEESubscription,
    DatapassWebhook::APIParticulier::CreateFormulaireQFCollectivity

  around do |interactor|
    interactor.call
  rescue StandardError => e
    Sentry.set_context(
      'DataPass webhook: create FormulaireQF resources',
      payload: {
        authorization_request_id: context.authorization_request.id
      }
    )

    Sentry.capture_exception(e)
  end
end
