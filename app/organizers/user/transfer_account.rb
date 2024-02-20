class User::TransferAccount < ApplicationOrganizer
  organize User::FindOrCreateNewOwner,
    User::TransferTokens,
    User::NotifyNewTokensOwner

  after do
    Sentry.set_extras(
      current_owner_id: context.current_owner.id
    )
    Sentry.capture_message('User::TransferAccount completed', level: :info)
  end
end
