class JwtAPIEntreprise::Contract::Update < Reform::Form
  property :blacklisted
  property :archived

  validation do
    json do
      optional(:blacklisted).filled(:bool?)
      optional(:archived).filled(:bool?)
    end
  end
end
