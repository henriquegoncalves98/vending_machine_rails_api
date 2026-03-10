# spec/controllers/products_controller_spec.rb
require 'rails_helper'

RSpec.describe ProductsController, type: :controller do
  let(:valid_attributes) { { name: 'Coke', stock: 10, price: 1.50 } }
  let(:invalid_attributes) { { name: '', stock: -1, price: -0.50 } }

  let!(:product1) { create(:product, stock: 1, price: 2.20) }
  let!(:product2) { create(:product, stock: 5, price: 1.44) }
  let!(:product3) { create(:product, stock: 0, price: 1.00) }

  describe 'GET #index' do
    context 'with pagination' do
      it 'returns all products (in stock and out of stock)' do
        get :index, params: { page: 1 }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['data'].size).to eq(3)
        expect(json['meta']['total_count']).to eq(3)
      end

      it 'includes pagination meta' do
        get :index

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['meta']).to have_key('current_page')
        expect(json['meta']).to have_key('total_pages')
      end

      it 'only includes specified fields' do
        get :index

        json = JSON.parse(response.body)['data'].first
        expect(json).to have_key('id')
        expect(json).to have_key('name')
        expect(json).to have_key('price')
        expect(json).to have_key('stock')
        expect(json).not_to have_key('created_at')
      end
    end
  end

  describe 'GET #show' do
    it 'returns a specific product' do
      get :show, params: { id: product1.id }

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['id']).to eq(product1.id)
    end

    it 'returns 404 for non-existent product' do
      get :show, params: { id: 0 }

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new product' do
        expect {
          post :create, params: { product: valid_attributes }
        }.to change(Product, :count).by(1)

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json['name']).to eq('Coke')
      end
    end

    context 'with invalid params' do
      it 'returns validation errors' do
        post :create, params: { product: invalid_attributes }

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['errors']['name']).to include("can't be blank")
        expect(json['errors']['stock']).to include('must be greater than or equal to 0')
      end

      it 'does not create product' do
        expect {
          post :create, params: { product: invalid_attributes }
        }.not_to change(Product, :count)
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      it 'updates the product' do
        new_attrs = { name: 'Coke Zero', stock: 20, price: 1.80 }
        put :update, params: { id: product1.id, product: new_attrs }

        expect(response).to have_http_status(:ok)
        product1.reload
        expect(product1.name).to eq('Coke Zero')
        expect(product1.stock).to eq(20)
        expect(product1.price).to eq(1.80)
      end
    end

    context 'with invalid params' do
      it 'returns validation errors' do
        put :update, params: { id: product1.id, product: invalid_attributes }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(product1.reload.stock).to eq(1) # No change
      end
    end

    it 'returns 404 for non-existent product' do
      put :update, params: { id: 0, product: valid_attributes }

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'DELETE #destroy' do
    it 'deletes the product' do
      expect {
        delete :destroy, params: { id: product1.id }
      }.to change(Product, :count).by(-1)

      expect(response).to have_http_status(:no_content)
      expect { product1.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'returns 404 for non-existent product' do
      delete :destroy, params: { id: 999 }

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST #refill' do
    before do
      request.headers['Accept'] = 'application/json'
    end

    context 'when refill success' do
      it 'returns success status and updated count' do
        post :refill

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['message']).to eq('All products refilled')
        expect(JSON.parse(response.body)['updated_count']).to eq(3)
      end

      it 'updates all product stocks to max' do
        expect {
          post :refill
        }.to change { product1.reload.stock }.from(1).to(10)
          .and change { product2.reload.stock }.from(5).to(10)
          .and change { product3.reload.stock }.from(0).to(10)
      end
    end

    context 'when refill fails' do
      before do
        # Simulate failure by adding invalid constraint
        allow(Product).to receive(:update_all).and_return(false)
      end
      it 'returns unprocessable_content status and error message' do
        post :refill

        expect(response).to have_http_status(:unprocessable_content)
        expect(JSON.parse(response.body)['message']).to eq('Products refill failed')
      end

      it 'does not change product stocks (rollback)' do
        expect {
          post :refill
        }.not_to change { product1.reload.stock }
      end
    end
  end

  describe 'POST #purchase' do
    let!(:product) { create(:product, name: 'Sprite', stock: 2, price: 1.50) }
    let(:purchase_params) { { amount: 2.00 } }  # Enough for 1 Sprite
    let!(:coin) { create(:coin, denomination: 50) }

    context 'when purchase succeeds' do
      it 'returns change and updated stock' do
        post :purchase, params: { id: product.id, amount: purchase_params[:amount] }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['change']).to be_an(Array)
        expect(json['total_change']).to be >= 0
        expect(json['stock']).to eq(1)  # Reduced by 1
      end
    end

    context 'when invalid amount submitted' do
      it 'returns bad request error' do
        allow(PurchaseItemService).to receive(:call).and_raise(MiscellaneousErrors::InvalidAmountSubmitted.new('Amount too low'))

        post :purchase, params: { id: product.id, amount: 0.50 }

        expect(response).to have_http_status(:bad_request)
        json = JSON.parse(response.body)
        expect(json['error']).to eq('Amount too low')
      end
    end

    context 'when product out of stock' do
      before { product.update!(stock: 0) }

      it 'returns bad request error' do
        allow(PurchaseItemService).to receive(:call).and_raise(MiscellaneousErrors::ProductOutOfStock.new('Out of stock'))

        post :purchase, params: { id: product.id, amount: 2.00 }

        expect(response).to have_http_status(:bad_request)
        json = JSON.parse(response.body)
        expect(json['error']).to eq('Out of stock')
      end
    end

    context 'when not enough change' do
      it 'returns unprocessable error' do
        allow(PurchaseItemService).to receive(:call).and_raise(MiscellaneousErrors::NotEnoughChange.new('No change available'))

        post :purchase, params: { id: product.id, amount: 5.00 }

        expect(response).to have_http_status(:unprocessable_entity)  # 422
        json = JSON.parse(response.body)
        expect(json['error']).to eq('No change available')
      end
    end

    context 'when product not found' do
      it 'returns 404' do
        post :purchase, params: { id: 0, amount: 2.00 }

        expect(response).to have_http_status(:not_found)
      end
    end
  end
end