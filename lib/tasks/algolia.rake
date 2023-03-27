namespace :algolia do
  desc 'Reindex models on Algolia'
  task reindex: :environment do
    AlgoliaReindexer.new.perform
  end
end
