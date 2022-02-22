class User
  class Login < ApplicationOrganizer
    organize User::FindFromEmail,
      User::UpdateOAuthAPIGouvId,
      User::NotifyDatapassOfTokenOwnership
  end
end
