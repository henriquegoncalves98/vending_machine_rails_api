require 'rails_helper'

RSpec.describe Product, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      product = Product.new(name: 'Coke', stock: 10, price: 1.50)
      expect(product).to be_valid
    end

    it 'requires name' do
      product = Product.new(stock: 10, price: 1.50)
      expect(product).not_to be_valid
      expect(product.errors[:name]).to include("can't be blank")
    end

    it 'rejects name longer than 200 chars' do
      long_name = 'A' * 201
      product = Product.new(name: long_name, stock: 10, price: 1.50)
      expect(product).not_to be_valid
      expect(product.errors[:name].first).to include('is too long')
    end

    it 'requires unique name (case insensitive)' do
      Product.create!(name: 'Coke', stock: 10, price: 1.50)
      duplicate = Product.new(name: 'coke', stock: 5, price: 1.20)
      expect(duplicate).not_to be_valid
    end

    it 'allows stock >= 0' do
      product = Product.new(name: 'Water', stock: 0, price: 0.50)
      expect(product).to be_valid
    end

    it 'rejects negative stock' do
      product = Product.new(name: 'Water', stock: -1, price: 0.50)
      expect(product).not_to be_valid
    end

    it 'allows price >= 0.0' do
      product = Product.new(name: 'Juice', stock: 5, price: 2.99)
      expect(product).to be_valid
    end

    it 'rejects negative price' do
      product = Product.new(name: 'Juice', stock: 5, price: -0.50)
      expect(product).not_to be_valid
    end
  end
end
