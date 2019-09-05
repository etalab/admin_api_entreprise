module JwtApiEntreprise::Contract
  AdminCreate = Dry::Validation.Schema do
    required(:roles) { filled? { each { str? } } }
    required(:user_id).filled(:str?)
    required(:subject).maybe(:str?)
  end
end
