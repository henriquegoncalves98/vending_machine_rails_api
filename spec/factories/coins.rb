FactoryBot.define do
  factory :coin do
    sequence(:denomination) { |n| [200, 100, 50, 20, 10, 5, 2, 1][n % 8] }
    stock { 10 }
  end
end
