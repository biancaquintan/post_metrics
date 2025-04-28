FactoryBot.define do
  factory :rating do
    association :user
    association :post
    value { rand(1..5) }
  end
end
