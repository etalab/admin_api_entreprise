class DatapassWebhook::ScheduleCreateFormulaireQFHubEESubscriptionJob < ApplicationInteractor
  def call
    return unless context.event == 'approve'
    return unless context.modalities.include?('formulaire_qf')

    CreateFormulaireQFHubEESubscriptionJob.perform_later(context.authorization_request.id)
  end
end
