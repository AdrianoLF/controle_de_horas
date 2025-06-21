FactoryBot.define do
  factory :membership do
    association :team
    association :member
    role { :member }

    trait :leader do
      role { :leader }
    end
  end
end
