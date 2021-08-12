class ApplicationRecord < ActiveRecord::Base
  # Now UUID are used as models ID we cannot use it to assume the creation
  # order as the Rails default behaviour, so we use the creation timestamp
  default_scope -> { order(created_at: :asc) }

  self.abstract_class = true
end
