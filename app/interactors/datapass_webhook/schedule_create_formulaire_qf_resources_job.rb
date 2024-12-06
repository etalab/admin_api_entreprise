class DatapassWebhook::ScheduleCreateFormulaireQFResourcesJob < ApplicationInteractor
  def call
    return unless context.event == 'approve'
    return unless context.modalities.include?('formulaire_qf')

    CreateFormulaireQFResourcesJob.perform_later(context.authorization_request.id)
  end
end
