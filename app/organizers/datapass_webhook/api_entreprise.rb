module DatapassWebhook
  class APIEntreprise < ApplicationOrganizer
    before do
      context.api = 'entreprise'
    end

    organize ::DatapassWebhook::FindOrCreateUser,
      ::DatapassWebhook::FindOrCreateAuthorizationRequest,
      ::DatapassWebhook::FindOrCreateOrganization,
      ::DatapassWebhook::CreateOrProlongToken,
      ::DatapassWebhook::ArchivePreviousAuthorizationRequest,
      ::DatapassWebhook::ArchiveCurrentAuthorizationRequest,
      ::DatapassWebhook::RefuseCurrentAuthorizationRequest,
      ::DatapassWebhook::RevokeCurrentToken,
      ::DatapassWebhook::UpdateMailjetContacts,
      ::DatapassWebhook::ExtractMailjetVariables,
      ::DatapassWebhook::ScheduleAuthorizationRequestEmails
  end
end
