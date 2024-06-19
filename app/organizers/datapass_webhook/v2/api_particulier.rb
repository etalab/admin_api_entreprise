module DatapassWebhook::V2
  class APIParticulier < ApplicationOrganizer
    before do
      context.api = 'particulier'
    end

    organize ::DatapassWebhook::AdaptV2ToV1,
      ::DatapassWebhook::APIParticulier
  end
end
