
class PurchaseItemService < BaseService
  include MiscellaneousErrors

  attr_reader :product, :amount

  def initialize(product, amount)
    @product = product
    @amount = amount.to_f
    @change = []
    @coins_to_decrement = {}
  end

  def call
    raise InvalidAmountSubmitted, 'You can\'t have a negative amount' if amount.negative?
    raise InvalidAmountSubmitted, 'You didn\'t insert enough money' if amount < product.price
    raise ProductOutOfStock, 'Product selected is out of stock!' if product.stock.zero?
    
    return decrement_stock if amount == product.price

    # when we have a surplus and need to give change
    fetch_available_coins
    @change = get_change(amount - product.price)
    decrement_stock
  end

  def decrement_stock
      product.decrement(:stock)
      product.save!

      decrement_coins
      @change
  end

  def decrement_coins
    @coins_to_decrement.each do |denomination, decrement|
      coin = Coin.find_by(denomination:)
      coin.update!(stock: coin.stock - decrement)
    end
  end

  def get_change(surplus)
    # gets the remaining value in pennies
    remaining = (surplus * 1e2).to_i
    change = []

    @coins.each_with_index do |coin, index|
      break if remaining.zero?

      while remaining >= coin
        change.push(coin)
        @coins_to_decrement[coin] = @coins_to_decrement[coin].to_i + 1
        remaining -= coin

        # decrease coin stock
        @stocks[index] -= 1
        break if @stocks[index].zero?
      end
    end

    raise NotEnoughChange, 'Not enough change, transaction failed' if remaining > 0
    change
  end

  private

  def fetch_available_coins
    valid_coins = Coin.select(:denomination, :stock).where('stock > 0').order(denomination: :DESC)
    @coins = valid_coins.pluck(:denomination)
    @stocks = valid_coins.pluck(:stock)
  end
end