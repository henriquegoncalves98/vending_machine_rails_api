# spec/controllers/coins_controller_spec.rb
require 'rails_helper'

RSpec.describe CoinsController, type: :controller do
  describe 'POST #refill' do
    let!(:coin1) { create(:coin, denomination: 100, stock: 10) }
    let!(:coin2) { create(:coin, denomination: 50, stock: 5) }

    before do
      request.headers['Accept'] = 'application/json'
    end

    context 'when refill success' do
      it 'returns success status and updated count' do
        post :refill

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['message']).to eq('All coins refilled')
        expect(JSON.parse(response.body)['updated_count']).to eq(2)
      end

      it 'updates all coin stocks to max' do
        expect {
          post :refill
        }.to change { coin1.reload.stock }.from(10).to(100)
          .and change { coin2.reload.stock }.from(5).to(100)
      end
    end

    context 'when refill fails' do
      before do
        # Simulate failure by adding invalid constraint
        allow(Coin).to receive(:update_all).and_return(false)
      end
      it 'returns unprocessable_content status and error message' do
        post :refill

        expect(response).to have_http_status(:unprocessable_content)
        expect(JSON.parse(response.body)['message']).to eq('Coins refill failed')
      end

      it 'does not change coin stocks (rollback)' do
        expect {
          post :refill
        }.not_to change { coin1.reload.stock }
      end
    end
  end
end