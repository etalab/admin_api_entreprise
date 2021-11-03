class OAuthAPIGouv::Contract::Login < Dry::Validation::Contract
  json do
    required(:authorization_code).filled(:str?)
  end
end
