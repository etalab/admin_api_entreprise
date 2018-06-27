class JwtApiEntreprise
  module Contract
    UserCreate = Dry::Validation.Schema do
      required(:roles) { filled? { each { str? } } }
      required(:user_id).filled(:str?)
      required(:subject).filled(:str?)

      required(:contact).schema do
        required(:email).filled(
          format?: /\A[a-zA-Z0-9_.+\-]+@[a-zA-Z0-9\-]+\.[a-zA-Z0-9\-.]+\z/
        )
        optional(:phone_number).filled(format?: /\A0\d(\d{2}){4}\z/)
      end
    end
  end
end
