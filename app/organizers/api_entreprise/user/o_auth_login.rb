class APIEntreprise::User::OAuthLogin < ApplicationOrganizer
  organize User::FindOrCreateThroughOAuth,
    User::UpdateOAuthAPIGouvId,
    User::NotifyDatapassOfTokenOwnership
end
