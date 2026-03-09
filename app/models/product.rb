class Product < ApplicationRecord
  validates :name,
            presence: true,
            length: { maximum: 200 },
            uniqueness: { case_sensitive: false }

  validates :stock, 
            presence: true,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  validates :price, 
            presence: true,
            numericality: { greater_than_or_equal_to: 0 }
end
