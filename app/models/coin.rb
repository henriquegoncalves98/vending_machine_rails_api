class Coin < ApplicationRecord
  validates :denomination,
            presence: true,
            uniqueness: true,  # No duplicate denominations
            numericality: { only_integer: true, greater_than: 0 }

  validates :stock, 
            presence: true,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
