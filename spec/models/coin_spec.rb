require 'rails_helper'

RSpec.describe Coin, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      coin = Coin.new(denomination: 100, stock: 50)
      expect(coin).to be_valid
    end

    it 'requires denomination' do
      coin = Coin.new(stock: 50)
      expect(coin).not_to be_valid
      expect(coin.errors[:denomination]).to include("can't be blank")
    end

    it 'requires unique denomination' do
      Coin.create!(denomination: 100, stock: 50)
      duplicate = Coin.new(denomination: 100, stock: 20)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:denomination]).to include("has already been taken")
    end

    it 'requires denomination > 0' do
      coin = Coin.new(denomination: 0, stock: 10)
      expect(coin).not_to be_valid
      expect(coin.errors[:denomination]).to include("must be greater than 0")
    end

    it 'allows stock >= 0' do
      coin = Coin.new(denomination: 100, stock: 0)
      expect(coin).to be_valid
    end

    it 'rejects negative stock' do
      coin = Coin.new(denomination: 100, stock: -1)
      expect(coin).not_to be_valid
      expect(coin.errors[:stock]).to include("must be greater than or equal to 0")
    end
  end
end
