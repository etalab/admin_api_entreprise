module User::Contract
  class CreateGhost < Reform::Form
    property :email
    property :context

    validation do
      required(:email).filled(format?: ParamsValidation::EmailRegex)
      required(:context).filled(:str?)
    end
  end
end
