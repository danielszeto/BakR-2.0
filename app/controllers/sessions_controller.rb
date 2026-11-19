class SessionsController < ApplicationController
  rate_limit to: 10, within: 3.minutes, only: :create

  def new
    @return_to = listing_return_path
  end

  def create
    credentials = params.expect(user: %i[email password])
    @return_to = listing_return_path
    @email = credentials[:email]
    if (user = User.authenticate_by(email: credentials[:email], password: credentials[:password]))
      login(user)
      redirect_to(@return_to || user)
    else
      flash.now[:alert] = "Check your email and password and try again."
      render :new, status: 422
    end
  end

  def destroy
    reset_session
    redirect_to root_path, status: :see_other, notice: "You’re signed out."
  end

  private

  def listing_return_path
    path = params[:return_to].to_s
    path if path.match?(/\A\/products\/\d+\z/)
  end
end
