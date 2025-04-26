FactoryBot.define do
  factory :post do
    association :user
    title { 'Test Post' }
    body { 'This is a test post' }
    ip { '100.0.0.1' }
  end
end
