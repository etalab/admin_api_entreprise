return unless %w[development sandbox].include?(Rails.env)

seeds = Seeds.new

seeds.flushdb
seeds.perform
