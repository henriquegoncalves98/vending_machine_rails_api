# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

Product.create!(name: 'Kit Kat', stock: 1, price: 1.7)
Product.create!(name: 'Kinder Bueno', stock: 1, price: 2.0)
Product.create!(name: 'Twix', stock: 1, price: 1.55)
Product.create!(name: 'Oreo', stock: 1, price: 1.99)
Product.create!(name: 'Water (50cl)', stock: 1, price: 1.44)
Product.create!(name: 'Ice Tea', stock: 1, price: 2.2)
Product.create!(name: 'Coca Cola', stock: 1, price: 2.2)
Product.create!(name: 'Latte', stock: 1, price: 2.13)

Coin.create!(denomination: 1, stock: 5)
Coin.create!(denomination: 2, stock: 5)
Coin.create!(denomination: 5, stock: 5)
Coin.create!(denomination: 10, stock: 5)
Coin.create!(denomination: 20, stock: 5)
Coin.create!(denomination: 50, stock: 5)
Coin.create!(denomination: 100, stock: 5)
Coin.create!(denomination: 200, stock: 5)