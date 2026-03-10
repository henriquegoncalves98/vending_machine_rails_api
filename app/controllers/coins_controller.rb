class CoinsController < ApplicationController
  VENDING_MACHINE_MAX_COIN_STOCK = 100

  def refill
    success = Coin.transaction do
      Coin.update_all(stock: VENDING_MACHINE_MAX_COIN_STOCK)
    end

    if success
      render json: { 
        message: 'All coins refilled',
        updated_count: Coin.count 
      }
    else
      render json: { 
        message: 'Coins refill failed'
      }, status: :unprocessable_content
    end
  end
end
