module JwtApiEntreprise::Contract
  class Update < Reform::Form
    property :blacklisted
    property :archived

    validation do
      optional(:blacklisted).filled(:bool?)
      optional(:archived).filled(:bool?)
    end
  end
end
