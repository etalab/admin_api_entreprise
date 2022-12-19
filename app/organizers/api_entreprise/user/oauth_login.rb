class APIEntreprise::User::OAuthLogin < ApplicationOrganizer
  organize User::FindFromEmail,
    User::UpdateOAuthAPIGouvId,
    User::NotifyDatapassOfTokenOwnership
end
