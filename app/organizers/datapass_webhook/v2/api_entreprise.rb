module DatapassWebhook::V2
  class APIEntreprise < ApplicationOrganizer
    before do
      context.api = 'entreprise'
    end

    organize ::DatapassWebhook::AdaptV2ToV1,
      ::DatapassWebhook::APIEntreprise
  end
end
