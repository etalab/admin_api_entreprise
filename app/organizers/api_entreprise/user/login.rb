class APIEntreprise::User::Login < ApplicationOrganizer
  organize User::FindFromEmail,
    User::UpdateOAuthAPIGouvId,
    User::NotifyDatapassOfTokenOwnership
end
