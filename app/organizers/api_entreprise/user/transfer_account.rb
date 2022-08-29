class APIEntreprise::User::TransferAccount < ApplicationOrganizer
  organize User::FindOrCreateNewOwner,
    User::TransferTokens,
    User::NotifyNewTokensOwner
end
