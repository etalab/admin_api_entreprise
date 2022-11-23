return unless %w[development sandbox staging].include?(Rails.env)

seeds = Seeds.new

seeds.flushdb

if Rails.env.staging?
  seeds.create_scopes_particulier
  seeds.create_scopes_entreprise
else
  seeds.perform
end
