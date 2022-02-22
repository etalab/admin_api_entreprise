class User::SyncOAuthAPIGouvData < ApplicationOrganizer
  organize User::UpdateOAuthAPIGouvId,
    User::NotifyDatapassOfTokenOwnership
end
