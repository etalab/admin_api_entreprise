class User::Contract::CreateGhost < Reform::Form
  property :email
  property :context

  validation do
    json do
      required(:email).filled(format?: ParamsValidation::EmailRegex)
      required(:context).filled(:str?)
    end
  end
end
