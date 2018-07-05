class Incident
  module Contract
    class Save < Reform::Form
      property :title
      property :subtitle
      property :description

      validation do
        required(:title).filled(:str?, max_size?: 128)
        required(:subtitle).filled(:str?, max_size?: 128)
        required(:description).filled(:str?)
      end
    end
  end
end
