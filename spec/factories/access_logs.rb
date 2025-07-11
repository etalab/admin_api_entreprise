FactoryBot.define do
  factory :access_log do
    timestamp { Time.zone.now }
    request_id { SecureRandom.uuid }
    path { "/v3/entreprises/#{rand(100_000_000..999_999_999)}" }

    token
  end
end
