class ProductsController < ApplicationController
  VENDING_MACHINE_MAX_STOCK = 10
  
  before_action :set_product, only: %i[show update destroy purchase]

  def index
    page = 1 if params[:page].to_i <= 0
    per_page = 50
    offset = (page - 1) * per_page

    products = Product
      .select(:id, :name, :price, :stock)
      .order(:name)
      .limit(per_page)
      .offset(offset)

    total_count = Product.count

    render json: {
      data: products,
      meta: {
        current_page: page,
        total_pages: (total_count.to_f / per_page).ceil,
        total_count:
      }
    }
  end

  def show
    render json: @product
  end

  def create
    product = Product.new(product_params)
    
    if product.save
      render json: product, status: :created
    else
      render json: { errors: product.errors }, status: :unprocessable_content
    end
  end

  def update
    if @product.update(product_params)
      render json: @product.reload
    else
      render json: { errors: @product.errors }, status: :unprocessable_content
    end
  end

  def destroy
    @product.destroy
    head :no_content
  end

  def purchase
    change = PurchaseItemService.call(@product, params[:amount])

    render json: { change: , total_change: change.reduce(:+), stock: @product.reload.stock }
  rescue InvalidAmountSubmitted, ProductOutOfStock => e
    render json: { error: e.message }, status: :bad_request
  rescue NotEnoughChange, StandardError => e
    render json: { error: e.message }, status: :unprocessable_content
  end

  def refill
    success = Product.transaction do
      Product.update_all(stock: VENDING_MACHINE_MAX_STOCK)
    end

    if success
      render json: { 
        message: 'All products refilled',
        updated_count: Product.count
      }
    else
      render json: { 
        message: 'Products refill failed'
      }, status: :unprocessable_content
    end
  end

  private

  def set_product
    @product = Product.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Product not found' }, status: :not_found and return
  end

  def product_params
    params.require(:product).permit(:name, :stock, :price)
  end
end
