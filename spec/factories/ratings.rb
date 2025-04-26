FactoryBot.define do
  factory :rating do
    association :user
    association :post
    value { 5 }
  end
end
