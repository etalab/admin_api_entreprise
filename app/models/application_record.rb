class ApplicationRecord < ActiveRecord::Base
  # Now UUID are used as models ID we cannot use it to assume the creation
  # order as the Rails default behaviour, so we use the creation timestamp
  self.abstract_class = true

  EMAIL_FORMAT_REGEX = /\A[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9\-.]+\z/
end
