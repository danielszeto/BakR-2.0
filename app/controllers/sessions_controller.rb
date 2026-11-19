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

  def google
    return google_failure unless Rails.configuration.x.google_sign_in

    auth = request.env["omniauth.auth"]
    uid = auth&.uid.to_s.presence
    email = User.normalize_value_for(:email, auth&.info&.email)
    verified = auth&.dig("extra", "raw_info", "email_verified").to_s == "true"
    return google_failure unless uid && email.present? && verified

    if current_user
      connect_google(uid, email)
    else
      sign_in_with_google(auth, uid, email)
    end
  rescue ActiveRecord::RecordNotUnique
    google_failure
  end

  def google_failure
    redirect_to current_user || sign_in_path, alert: "Google sign-in couldn’t be completed. Please try again."
  end

  private

  def sign_in_with_google(auth, uid, email)
    user = User.find_by(google_uid: uid)
    if user.nil?
      if User.exists?(email: email)
        return redirect_to sign_in_path, alert: "Sign in with your password first, then connect Google from your profile."
      end

      first_name = auth.info.first_name.presence || auth.info.name.presence || "BakR member"
      user = User.create(
        google_uid: uid, email: email, first_name: first_name[0, 80],
        last_name: auth.info.last_name&.slice(0, 80), password: SecureRandom.hex(24)
      )
      return google_failure unless user.persisted?
    end

    login(user)
    redirect_to(listing_return_path(request.env.dig("omniauth.params", "return_to")) || user)
  end

  def connect_google(uid, email)
    if current_user.email != email
      return redirect_to current_user, alert: "Use a Google account with the same email as your BakR account."
    end

    if current_user.google_uid.present? && current_user.google_uid != uid
      return redirect_to current_user, alert: "Your profile already has a connected Google account."
    end

    current_user.update!(google_uid: uid)
    redirect_to current_user, notice: "Google is connected to your BakR account."
  end

  def listing_return_path(value = params[:return_to])
    path = value.to_s
    path if path.match?(/\A\/products\/\d+\z/)
  end
end
