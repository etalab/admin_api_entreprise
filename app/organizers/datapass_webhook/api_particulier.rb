module DatapassWebhook
  class APIParticulier < ApplicationOrganizer
    organize ::DatapassWebhook::FindOrCreateUser,
      ::DatapassWebhook::FindOrCreateAuthorizationRequest,
      ::DatapassWebhook::CreateToken
  end
end
