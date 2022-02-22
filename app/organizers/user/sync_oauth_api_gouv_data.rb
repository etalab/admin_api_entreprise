class User
  class SyncOAuthAPIGouvData < ApplicationOrganizer
    organize User::UpdateOAuthAPIGouvId,
      User::NotifyDatapassOfTokenOwnership
  end
end
