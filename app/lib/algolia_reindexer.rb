class AlgoliaReindexer
  def perform
    Rails.application.eager_load!

    indexable_models.each(&:reindex)
  rescue Algolia::AlgoliaError => e
    Rails.logger.debug { "AlgoliaReindexer: Fail to reindex models: #{e.message}\n" }
  end

  private

  def indexable_models
    indexable_active_models + indexable_active_record_models
  end

  def indexable_active_models
    ApplicationAlgoliaSearchableActiveModel.descendants
  end

  def indexable_active_record_models
    ActiveRecord::Base.descendants.select do |model|
      model.respond_to?(:reindex)
    end
  end
end
