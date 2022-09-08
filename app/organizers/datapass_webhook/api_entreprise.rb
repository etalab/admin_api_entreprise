module DatapassWebhook
  class APIEntreprise < ApplicationOrganizer
    before do
      context.api = 'entreprise'
    end

    organize ::DatapassWebhook::FindOrCreateUser,
      ::DatapassWebhook::FindOrCreateAuthorizationRequest,
      ::DatapassWebhook::CreateToken,
      ::DatapassWebhook::ArchivePreviousToken,
      ::DatapassWebhook::UpdateMailjetContacts,
      ::DatapassWebhook::ExtractMailjetVariables,
      ::DatapassWebhook::ScheduleAuthorizationRequestEmails
  end
end
