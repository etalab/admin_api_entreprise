module DatapassWebhook
  class APIParticulier < ApplicationOrganizer
    before do
      context.token_create_extra_params = {
        extra_info: {
          'legacy_token_id' => context.data['external_token_id']
        }.compact
      }

      context.api = 'particulier'
      context.authorization_request_data ||= {}
      context.modalities = context.authorization_request_data['modalities'].presence || %w[params]
    end

    organize ::DatapassWebhook::FindOrCreateUser,
      ::DatapassWebhook::FindOrCreateAuthorizationRequest,
      ::DatapassWebhook::FindOrCreateOrganization,
      ::DatapassWebhook::CreateOrProlongToken,
      ::DatapassWebhook::ArchiveCurrentAuthorizationRequest,
      ::DatapassWebhook::RefuseCurrentAuthorizationRequest,
      ::DatapassWebhook::RevokeCurrentToken,
      ::DatapassWebhook::UpdateMailjetContacts,
      ::DatapassWebhook::ScheduleCreateFormulaireQFResourcesJob,
      ::DatapassWebhook::ExtractMailjetVariables,
      ::DatapassWebhook::ScheduleAuthorizationRequestEmails,
      ::DatapassWebhook::APIParticulier::NotifyReporters
  end
end
