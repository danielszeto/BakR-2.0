class ProductsController < ApplicationController
  before_action :require_login, except: %i[index show]
  before_action :set_product, only: %i[show edit update destroy]
  before_action :require_owner, only: %i[edit update destroy]

  def index
    @category = params[:type].to_s.downcase.presence_in(Product::CATEGORIES.keys)
    @products = Product.where(available: true).includes(:user).order(created_at: :desc, id: :desc)
    @products = @products.where(category: @category) if @category
  end

  def new
    @product = current_user.products.build(category: "regular")
  end

  def create
    @product = current_user.products.build(product_params)
    if @product.save
      redirect_to @product, notice: "Listing created."
    else
      render :new, status: 422
    end
  end

  def show
  end

  def edit
  end

  def update
    if @product.update(product_params)
      redirect_to @product, notice: "Listing updated."
    else
      render :edit, status: 422
    end
  end

  def destroy
    @product.destroy!
    redirect_to current_user, status: :see_other, notice: "Listing deleted."
  end

  private

  def set_product
    @product = Product.find(params[:id])
  end

  def require_owner
    head :forbidden unless @product.user_id == current_user.id
  end

  def product_params
    params.expect(product: %i[title description category price available product_url])
  end
end
