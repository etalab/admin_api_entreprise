class User::TransferAccount < ApplicationOrganizer
  organize User::FindOrCreate,
           User::TransferTokens,
           User::NotifyNewTokensOwner
end
