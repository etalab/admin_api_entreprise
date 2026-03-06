FactoryBot.define do
  factory :editor do
    name { 'UMAD Editor' }
    form_uids do
      [
        'umad-editor'
      ]
    end

    trait :delegable do
      delegations_enabled { true }
    end
  end
end
