class ApplicationAlgoliaSearchableActiveModel
  include ActiveModel::Model

  def self.inherited(base)
    base.extend ClassMethods
    base.include AlgoliaSearch

    base.class_eval do
      private_class_method :values_includes_entry_attribute?
    end
  end

  module ClassMethods
    def algoliasearch_active_model(options = {}, &)
      algoliasearch(options.merge(id: :dom_id), &)
    end

    def all
      fail NotImplementedError
    end

    def unscoped
      yield
    end

    def where(conditions = {})
      return all if conditions.blank?

      all.select do |entry|
        conditions.all? do |attr, values|
          values_includes_entry_attribute?(entry, attr, values)
        end
      end
    end

    def values_includes_entry_attribute?(entry, attr, values)
      Array.wrap(values).include?(entry.public_send(attr))
    end
  end

  def id
    fail NotImplementedError
  end

  def dom_id
    "#{self.class.name.underscore}_#{id}"
  end
end
