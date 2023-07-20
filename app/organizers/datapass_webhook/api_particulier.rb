module DatapassWebhook
  class APIParticulier < ApplicationOrganizer
    before do
      context.token_create_extra_params = {
        extra_info: {
          'legacy_token_id' => context.data['external_token_id']
        }.compact
      }

      context.api = 'particulier'
    end

    organize ::DatapassWebhook::FindOrCreateUser,
      ::DatapassWebhook::FindOrCreateAuthorizationRequest,
      ::DatapassWebhook::CreateToken
  end
end
