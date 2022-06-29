namespace :algolia do
  desc 'Reindex models on Algolia'
  task reindex: :environment do
    Rails.application.eager_load!

    algolia_models = ApplicationAlgoliaSearchableActiveModel.descendants
    algolia_models.each(&:reindex)

    algolia_models = ActiveRecord::Base.descendants.select do |model|
      model.respond_to?(:reindex)
    end
    algolia_models.each(&:reindex)
  end
end
