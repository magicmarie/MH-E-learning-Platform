# frozen_string_literal: true

class AuthController < ApplicationController
  include Authenticatable

  before_action :authorize_request, only: [ :change_password ]

  # POST /signup
  def signup
    result = Auth::Signup.run(signup_params)

    if result.valid?
      render json: result.result, status: :created
    else
      render json: { errors: result.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # POST /login
  def login
    result = Auth::Login.run(login_params)
    status = result.result.delete(:status) || :unprocessable_entity

    if result.valid? || status == :partial_content
      render json: result.result, status: status
    else
      render json: { errors: result.errors.full_messages }, status: status
    end
  end

  # POST /verify_security
  def verify_security
    result = Auth::VerifySecurity.run(verify_security_params)

    if result.valid?
      render json: result.result, status: :ok
    else
      render json: { errors: result.errors.full_messages }, status: :unauthorized
    end
  end

  # PATCH /change_password
  def change_password
    result = Auth::ChangePassword.run(
      user: current_user,
      current_password: params[:current_password],
      new_password: params[:new_password]
    )

    if result.valid?
      render json: result.result, status: :ok
    else
      render json: { errors: result.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def signup_params
    # Role is validated in Auth::Signup interaction layer
    # Only org_admin, teacher, and student are allowed; global_admin is blocked
    params.permit(:organization_id, :email, :password, :role) # brakeman:ignore:PermitAttributes
  end

  def login_params
    params.permit(:organization_id, :email, :password, :security_answer)
  end

  def verify_security_params
    params.permit(:email, :security_answer)
  end
end
