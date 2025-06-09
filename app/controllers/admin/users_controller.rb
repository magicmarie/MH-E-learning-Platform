# app/controllers/admin/users_controller.rb

class Admin::UsersController < ApplicationController
  include Authenticatable
  include UserManagement

  before_action :authorize_request

  def create
    authorize User
    incoming_role = params[:role].to_sym
    role_int = Constants::Roles::ROLES[incoming_role]

    if role_int.blank?
      return render json: { error: "Unknown role '#{incoming_role}'" }, status: :unprocessable_entity
    end

    if role_int == Constants::Roles::ROLES[:global_admin]
      # Global admins cannot create other global admins
      return render json: { error: "Cannot create global_admin" }, status: :forbidden
    end

    # Global admins can only create org_admins, teachers, and students
    allowed_roles = [
      Constants::Roles::ROLES[:org_admin],
      Constants::Roles::ROLES[:teacher],
      Constants::Roles::ROLES[:student]
    ]
    unless allowed_roles.include?(role_int)
      return render json: { error: "Role #{incoming_role} not allowed" }, status: :unprocessable_entity
    end

    # Global admins must provide organization_id
    organization_id = params[:organization_id]
    organization = Organization.find_by(id: organization_id)

    unless organization
      return render json: { error: "Organization not found" }, status: :not_found
    end

    temp_password = SecureRandom.alphanumeric(8)
    user = organization.users.new(user_params.merge(
      role: role_int, password: temp_password, password_confirmation: temp_password))

    if user.save
      token = JsonWebToken.encode({ user_id: @user.id }, 15.minutes.from_now)
      reset_url = "#{root_url}reset_password?token=#{token}"

      begin
        UserMailer.welcome_user(user, temp_password, reset_url).deliver_now
      rescue => e
        Rails.logger.error("Failed to send welcome email to #{user.email}: #{e.message}")
      end

      render json: user, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  # Global admins can see all users
  def user_scope
    User.where.not(role: Constants::Roles::ROLES[:global_admin])
  end

  def user_params
    params.permit(:email)
  end
end
