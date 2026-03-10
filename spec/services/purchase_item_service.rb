# spec/services/purchase_item_service_spec.rb
require 'rails_helper'

RSpec.describe PurchaseItemService, type: :service do
  let(:product) { create(:product, name: 'Coke', stock: 2, price: 1.50) }
  let(:service) { described_class.new(product, amount) }

  describe 'PurchaseItemService #call (unlimited coins)' do
    let(:amount) { 2.13 }  # Creates 0.63 surplus

    before do
      create_list(:coin, 8, stock: 10)  # Full stock
    end

    context 'when surplus 0 (exact amount)' do
      let(:amount) { 1.50 }
      
      it 'returns empty change array' do
        expect(service.call).to eq([])
      end
    end

    context 'when surplus 0.01 EUR (1 cent)' do
      let(:amount) { 1.51 }
      
      it 'returns [1]' do
        expect(service.call).to eq([1])
      end
    end

    context 'when surplus 0.44 EUR' do
      let(:amount) { 1.94 }
      
      it 'returns [20, 20, 2, 2]' do
        expect(service.call).to eq([20, 20, 2, 2])
      end
    end

    context 'when surplus 0.63 EUR (from 2.13 total)' do
      let(:amount) { 2.13 }
      
      it 'returns [50, 10, 2, 1]' do
        expect(service.call).to eq([50, 10, 2, 1])
      end
    end

    context 'when negative amount' do
      let(:amount) { -1.0 }
      
      it 'raises InvalidAmountSubmitted' do
        expect { service.call }.to raise_error(MiscellaneousErrors::InvalidAmountSubmitted, "You can't have a negative amount")
      end
    end

    context 'when insufficient amount' do
      let(:amount) { 1.0 }
      
      it 'raises InvalidAmountSubmitted' do
        expect { service.call }.to raise_error(MiscellaneousErrors::InvalidAmountSubmitted, "You didn't insert enough money")
      end
    end
  end

  describe 'PurchaseItemService #call (limited coins)' do
    let(:amount) { 2.13 }

    context 'when coins insufficient for change' do
      before do
        create(:coin, denomination: 200, stock: 0)
        create(:coin, denomination: 100, stock: 0)
        create(:coin, denomination: 1, stock: 1)
      end

      it 'raises NotEnoughChange' do
        expect { service.call }.to raise_error(MiscellaneousErrors::NotEnoughChange, 'Not enough change, transaction failed')
      end
    end

    context 'when some coins run out mid-transaction' do
      let(:amount) { 1.94 }  # Needs [100,20,20,2,2] but limited stock

      before do
        create(:coin, denomination: 100, stock: 1)
        create(:coin, denomination: 20, stock: 1)
        create(:coin, denomination: 2, stock: 1)
        create(:coin, denomination: 1, stock: 2)
      end

      it 'uses available coins and raises when out' do
        expect { service.call }.to raise_error(MiscellaneousErrors::NotEnoughChange, 'Not enough change, transaction failed')
      end
    end
  end

  describe 'purchase validations' do
    let(:amount) { 1.50 }
    let!(:coin) { create(:coin, denomination: 50) }

    context 'when product out of stock' do
      before { product.update!(stock: 0) }

      it 'raises ProductOutOfStock before change calculation' do
        expect { service.call }.to raise_error(MiscellaneousErrors::ProductOutOfStock, 'Product selected is out of stock!')
      end
    end

    context 'when exact amount (no change needed)' do
      it 'decrements stock and returns empty change' do
        expect {
          service.call
        }.to change { product.reload.stock }.from(2).to(1)

        expect(service.call).to eq([])
      end
    end

    context 'when stock decrements correctly' do
      let(:amount) { 2.00 }

      it 'decrements stock once' do
        expect {
          service.call
        }.to change { product.reload.stock }.from(2).to(1)
      end
    end
  end

  # === INTEGRATION TESTS ===

  describe 'full purchase flow' do
    let(:amount) { 2.00 }
    
    before do
      # Full coin stock
      Coin.create!(denomination: 200, stock: 10)
      Coin.create!(denomination: 100, stock: 10)
      Coin.create!(denomination: 50, stock: 10)
      Coin.create!(denomination: 20, stock: 10)
      Coin.create!(denomination: 10, stock: 10)
      Coin.create!(denomination: 5, stock: 10)
      Coin.create!(denomination: 2, stock: 10)
      Coin.create!(denomination: 1, stock: 10)
    end

    it 'processes purchase, returns change, decrements stock and coins' do
      change = service.call
      expect(change).to eq([50])  # 2.00 - 1.50 = 0.50
      
      product.reload
      expect(product.stock).to eq(1)
      
      # Verify coin stock decreased
      coin_50 = Coin.find_by(denomination: 50)
      expect(coin_50.stock).to eq(9)
    end
  end
end
