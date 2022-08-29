class APIParticulier::User::Login < ApplicationOrganizer
  organize User::FindFromEmail,
    User::UpdateOAuthAPIGouvId
end
