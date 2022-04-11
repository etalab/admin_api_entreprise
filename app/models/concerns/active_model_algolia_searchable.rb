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
        conditions.all? do |attr, values|
          values_includes_entry_attribute?(entry, attr, values)
        end
      end
    end

    def self.values_includes_entry_attribute?(entry, attr, values)
      Array.wrap(values).include?(entry.public_send(attr))
    end

    private_class_method :values_includes_entry_attribute?
  end

  def id
    fail NotImplementedError
  end

  def dom_id
    "#{self.class.name.underscore}_#{id}"
  end
end
