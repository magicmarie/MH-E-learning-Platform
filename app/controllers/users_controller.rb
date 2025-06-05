# frozen_string_literal: true

class UsersController < ApplicationController
  include Authenticatable
  include UserManagement

  ROLE_MAP = {
    "global_admin" => User::GLOBAL_ADMIN,
    "org_admin"    => User::ORG_ADMIN,
    "teacher"      => User::TEACHER,
    "student"      => User::STUDENT
  }.freeze

  before_action :authorize_request

  def create
    incoming_role = params[:role].to_s
    role_int = ROLE_MAP[incoming_role]

    if role_int.blank?
      return render json: { error: "Unknown role '#{incoming_role}'" }, status: :unprocessable_entity
    end

    if role_int == User::GLOBAL_ADMIN || role_int == User::ORG_ADMIN
      return render json: { error: "Org admins cannot create '#{incoming_role}' users" }, status: :forbidden
    end

    allowed_roles = [ User::TEACHER, User::STUDENT ]
    unless allowed_roles.include?(role_int)
      return render json: { error: "Role '#{incoming_role}' not allowed" }, status: :unprocessable_entity
    end

    temp_password = SecureRandom.alphanumeric(8)
    user = current_user.organization.users.new(user_params.merge(
      role: role_int, password: temp_password, password_confirmation: temp_password))
    authorize user

    if user.save
      org_code = user.organization&.organization_code
      begin
        UserMailer.welcome_user(user, org_code, temp_password).deliver_now
      rescue => e
        Rails.logger.error("Failed to send welcome email to #{user.email}: #{e.message}")
      end

      render json: user, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def user_scope
    # Org admins only manage users in their org except global admins
    current_user.organization.users.where.not(role: User::GLOBAL_ADMIN)
  end

  def user_params
    params.permit(:email)
  end
end
