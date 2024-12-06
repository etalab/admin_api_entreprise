FactoryBot.define do
  factory :access_log do
    timestamp { Time.zone.now }

    token
  end
end
