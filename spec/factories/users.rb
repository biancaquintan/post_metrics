FactoryBot.define do
  factory :user do
    login { Faker::Internet.username }
  end
end
