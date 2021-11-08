class JwtAPIEntreprise::Contract::CreateMagicLink < Dry::Validation::Contract
  json do
    required(:id).filled(:str?)
    required(:email).filled(format?: ParamsValidation::EmailRegex)
  end
end
