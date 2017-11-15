class Role
  class Create < Trailblazer::Operation
    extend Contract::DSL

    contract do
      property :name
      property :code

      validation do
        required(:name).filled(:str?, max_size?: 50)
        required(:code).filled(:str?, max_size?: 4)
      end
    end

    step Model(Role, :new)
    step Contract::Build()
    step Contract::Validate()
    step Contract::Persist()
  end
end
