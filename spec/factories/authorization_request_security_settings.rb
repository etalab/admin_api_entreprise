FactoryBot.define do
  factory :authorization_request_security_settings do
    authorization_request
    rate_limit_per_minute { nil }
    allowed_ips { [] }
  end
end
