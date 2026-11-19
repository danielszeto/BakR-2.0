class UsersController < ApplicationController
  before_action :require_login, only: %i[edit update]
  before_action :set_user, only: %i[show edit update]
  before_action :require_self, only: %i[edit update]
  rate_limit to: 8, within: 10.minutes, only: :create

  def new
    @user = User.new
  end

  def create
    @user = User.new(profile_params.merge(params.expect(user: %i[email password password_confirmation])))
    if @user.save
      login(@user)
      redirect_to @user, notice: "Your profile is ready."
    else
      render :new, status: 422
    end
  rescue ActiveRecord::RecordNotUnique
    @user.errors.add(:email, :taken)
    render :new, status: 422
  end

  def show
    @products = @user.products.order(created_at: :desc, id: :desc)
    @products = @products.where(available: true) unless current_user == @user
  end

  def edit
  end

  def update
    if @user.update(profile_params)
      redirect_to @user, notice: "Profile updated."
    else
      render :edit, status: 422
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def require_self
    head :forbidden unless current_user == @user
  end

  def profile_params
    params.expect(user: %i[first_name last_name location bio contact_email])
  end
end
