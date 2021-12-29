class DatapassWebhook < ApplicationOrganizer
  organize ::DatapassWebhook::FindOrCreateUser,
           ::DatapassWebhook::FindOrCreateAuthorizationRequest,
           ::DatapassWebhook::CreateJwtToken,
           ::DatapassWebhook::ArchivePreviousToken,
           ::DatapassWebhook::UpdateMailjetContacts,
           ::DatapassWebhook::ExtractMailjetVariables,
           ::DatapassWebhook::ScheduleAuthorizationRequestEmails
end
