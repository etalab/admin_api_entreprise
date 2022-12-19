class APIParticulier::User::OAuthLogin < ApplicationOrganizer
  organize User::FindFromEmail,
    User::UpdateOAuthAPIGouvId
end
