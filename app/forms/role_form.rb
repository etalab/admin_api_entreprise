class RoleForm < Reform::Form
  property :name
  property :code

  validation do
    required(:name).filled(:str?, max_size?: 50)
    required(:code).filled(:str?, max_size?: 4)
  end
end
