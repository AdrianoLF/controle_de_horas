FactoryBot.define do
  factory :event do
    association :team
    title { Faker::Lorem.sentence(word_count: 3) }
    description { Faker::Lorem.paragraph }
    duration_seconds { [15.minutes, 30.minutes, 1.hour, 2.hours].sample.to_i }
    occurred_at { Faker::Date.between(from: 30.days.ago, to: Time.zone.today) }
  end
end
