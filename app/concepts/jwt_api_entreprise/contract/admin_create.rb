module JwtApiEntreprise::Contract
  AdminCreate = Dry::Validation.Schema do
    required(:roles) { filled? { each { str? } } }
    required(:user_id).filled(:str?)
    required(:subject).maybe(:str?)

    # TODO Now create contacts when creating a token
    # collection :contacts, form: Contact::Contract::Upsert, populate_if_empty: Contact
  end
end
