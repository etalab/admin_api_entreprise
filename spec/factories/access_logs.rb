FactoryBot.define do
  factory :access_log do
    timestamp { Time.zone.now.to_i }

    token
  end
end
