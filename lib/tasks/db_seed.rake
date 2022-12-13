namespace :db_seed do
  desc 'Seeds database in sandbox'

  task sandbox: :environment do
    return unless Rails.env.sandbox?

    seeds = Seeds.new

    seeds.flushdb
    seeds.perform
  end

  task staging: :environment do
    return unless Rails.env.staging?

    seeds = Seeds.new

    seeds.flushdb
    seeds.perform
  end
end
