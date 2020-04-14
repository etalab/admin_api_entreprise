module OAuthApiGouv::Contract
  Login = Dry::Validation.Schema do
    required(:authorization_code).filled(:str?)
  end
end
