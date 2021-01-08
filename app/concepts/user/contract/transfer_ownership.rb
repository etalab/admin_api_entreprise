module User::Contract
  TransferOwnership = Dry::Validation.Schema do
    required(:new_owner_email).filled(format?: /\A[a-zA-Z0-9_.+\-]+@[a-zA-Z0-9\-]+\.[a-zA-Z0-9\-.]+\z/)
  end
end
