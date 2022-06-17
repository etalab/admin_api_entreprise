class DatapassWebhook < ApplicationOrganizer
  organize ::DatapassWebhook::FindOrCreateUser,
    ::DatapassWebhook::FindOrCreateAuthorizationRequest,
    ::DatapassWebhook::CreateToken,
    ::DatapassWebhook::ArchivePreviousToken,
    ::DatapassWebhook::UpdateMailjetContacts,
    ::DatapassWebhook::ExtractMailjetVariables,
    ::DatapassWebhook::ScheduleAuthorizationRequestEmails
end
