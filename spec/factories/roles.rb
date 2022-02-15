FactoryBot.define do
  factory :role do
    sequence(:name) { |n| "Role #{n}" }
    sequence(:code, 0) { |n| "x#{n}x" }
  end

  trait :with_specific_role do
    transient do
      specific_role { 'entreprises' }
    end

    name { specific_role.humanize }
    code { specific_role }
  end
end
