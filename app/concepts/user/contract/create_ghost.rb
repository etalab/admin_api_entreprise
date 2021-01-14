module User::Contract
  class CreateGhost < Reform::Form
    property :email
    property :context

    validation do
      required(:email).filled(format?: /\A[a-zA-Z0-9_.+\-]+@[a-zA-Z0-9\-]+\.[a-zA-Z0-9\-.]+\z/)
      required(:context).filled(:str?)
    end
  end
end
