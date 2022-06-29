class ApplicationAlgoliaSearchableActiveModel
  include ActiveModel::Model
  include AlgoliaSearch
  include ActiveModelAlgoliaSearchable
end
