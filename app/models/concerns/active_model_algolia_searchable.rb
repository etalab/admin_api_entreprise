module ActiveModelAlgoliaSearchable
  extend ActiveSupport::Concern
  include AlgoliaSearch

  included do
    def self.algoliasearch_active_model(options = {}, &)
      algoliasearch(options.merge(id: :dom_id), &)
    end

    def self.all
      fail NotImplementedError
    end

    def self.unscoped
      yield
    end

    def self.where(conditions = {})
      return all if conditions.blank?

      all.select do |entry|
        conditions.all? do |key, values|
          Array.wrap(values).include?(entry.public_send(key))
        end
      end
    end
  end

  def id
    fail NotImplementedError
  end

  def dom_id
    "#{self.class.name.underscore}_#{id}"
  end
end
