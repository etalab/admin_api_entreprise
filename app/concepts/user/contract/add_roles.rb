class User
  module Contract
    AddRoles = Dry::Validation.Schema do
      required(:id).filled(:str?)
      required(:roles) { filled? { each { str? } } }
    end
  end
end
