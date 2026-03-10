FactoryBot.define do
  factory :product do
    sequence(:name) { |n| "Product #{n}" }
    stock { 1 }
    price { 2.20 }
  end
end
