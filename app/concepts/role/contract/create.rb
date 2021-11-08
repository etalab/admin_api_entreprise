class Role::Contract::Create < Reform::Form
  property :name
  property :code

  validation do
    json do
      required(:name).filled(:str?, max_size?: 50)
      required(:code).filled(:str?)
    end

    rule(:name) do
      key.failure('value already exists') unless Role.where(name: value).empty?
    end

    rule(:code) do
      key.failure('value already exists') unless Role.where(code: value).empty?
    end
  end
end
