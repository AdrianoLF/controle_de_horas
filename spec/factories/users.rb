FactoryBot.define do
  factory :user do
    email { Faker::Name.name + "@#{SecureRandom.uuid}.com" }
    password { 'Password1!' }
  end
end
