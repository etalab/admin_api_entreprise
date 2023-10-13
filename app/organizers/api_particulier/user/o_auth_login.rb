class APIParticulier::User::OAuthLogin < ApplicationOrganizer
  organize User::FindOrCreateThroughOAuth,
    User::UpdateOAuthAPIGouvId
end
