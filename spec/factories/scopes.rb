FactoryBot.define do
  factory :scope do
    sequence(:name) { |n| "Scope #{n}" }
    sequence(:code, 0) { |n| "x#{n}x" }
    api { %w[particulier entreprise].sample }
  end

  trait :with_specific_scope do
    transient do
      specific_scope { 'entreprises' }
    end

    name { specific_scope.humanize }
    code { specific_scope }
    api  { 'entreprise' }
  end
end
