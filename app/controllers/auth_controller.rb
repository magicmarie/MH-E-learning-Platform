# frozen_string_literal: true

class AuthController < ApplicationController
  def signup
    org = Organization.find(params[:organization_id])
    user = org.users.new(user_params)

    if user.save
      token = JsonWebToken.encode(user_id: user.id)
      render json: { token: token, user: user }, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def login
    user = if params[:organization_id].present?
      User.find_by(email: params[:email], organization_id: params[:organization_id])
    else
      User.find_by(email: params[:email])
    end

    # Authenticate password
    unless user&.authenticate(params[:password])
      return render json: { error: "Invalid credentials" }, status: :unauthorized
    end

    unless user.active?
      return render json: { error: "Account is deactivated" }, status: :unauthorized
    end

    # Extra check for global admins
    if user.global_admin?
      if params[:security_answer].blank?
        return render json: {
          message: "MFA"
        }, status: :partial_content
      end

      unless user.correct_security_answer?(params[:security_answer])
        return render json: { error: "Incorrect security answer" }, status: :unauthorized
      end
    end

    token = JsonWebToken.encode(user_id: user.id)
    render json: { token: token, user: user }, status: :ok
  end

  def verify_security
    user = User.find_by(email: params[:email])

    unless user&.global_admin?
      return render json: { error: "Unauthorized" }, status: :unauthorized
    end

    unless user.active?
      return render json: { error: "Account is deactivated" }, status: :unauthorized
    end

    unless user.correct_security_answer?(params[:security_answer])
      return render json: { error: "Incorrect security answer" }, status: :unauthorized
    end

    token = JsonWebToken.encode(user_id: user.id)
    render json: { token: token, user: user }, status: :ok
  end

  private

  def user_params
    params.permit(:email, :password, :role)
  end
end
