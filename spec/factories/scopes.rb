FactoryBot.define do
  factory :scope do
    sequence(:name) { |n| "Scope #{n}" }
    sequence(:code, 0) { |n| "x#{n}x" }
  end

  trait :with_specific_scope do
    transient do
      specific_scope { 'entreprises' }
    end

    name { specific_scope.humanize }
    code { specific_scope }
  end
end
