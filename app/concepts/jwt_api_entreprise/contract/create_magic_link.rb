module JwtAPIEntreprise::Contract
  CreateMagicLink = Dry::Validation.Schema do
    required(:id).filled(:str?)
    required(:email).filled(format?: ParamsValidation::EmailRegex)
  end
end
