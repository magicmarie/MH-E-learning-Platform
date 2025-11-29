# frozen_string_literal: true

class PasswordsController < ApplicationController
  skip_before_action :authorize_request
  before_action :validate_token, only: [ :update ]
  before_action :validate_password_params, only: [ :update ]

  def create
    user = User.find_by(email: params[:email])

    if user&.active?
      token = user.generate_reset_token(1.hour.from_now)
      reset_url = "http://localhost:5173/reset_password?token=#{token}"

      user.update!(reset_password_token_sent_at: Time.current)

      UserMailer.welcome_user(user, nil, reset_url).deliver_now

      render json: { message: "Password reset link sent to #{user.email}" }, status: :ok
    else
      render_error("Email not found or inactive", :not_found)
    end
  end

  def update
    user = User.find_by(id: @payload[:user_id])
    return render_error("User not found", :not_found) unless user

    # Prevent reuse: Check if token has already been used
    if user.reset_token_used_after?(@payload[:iat])
      return render_error("This reset link has already been used", :unauthorized)
    end

    if user.update(password_params)
      user.mark_reset_token_used!
      render json: { message: "Password updated successfully" }, status: :ok
    else
      render_error(user.errors.full_messages, :unprocessable_entity)
    end
  end

  private

  def password_params
    params.permit(:password, :password_confirmation)
  end

  def validate_token
    token = params[:token]
    return render_error("Token is required", :bad_request) if token.blank?

    begin
      @payload = JsonWebToken.decode(token)
      render_error("Token expired", :unauthorized) if @payload.blank?
    rescue JWT::ExpiredSignature
      render_error("Token has expired", :unauthorized)
    rescue JWT::DecodeError
      render_error("Invalid token", :unauthorized)
    end
  end

  def validate_password_params
    if params[:password].blank?
      render_error("Password is required", :bad_request) and return
    end

    if params[:password_confirmation].blank?
      render_error("Password confirmation is required", :bad_request) and return
    end

    if params[:password] != params[:password_confirmation]
      render_error("Passwords do not match", :unprocessable_entity) and return
    end
  end

  def render_error(message, status)
    render json: { errors: Array(message) }, status: status
  end
end
