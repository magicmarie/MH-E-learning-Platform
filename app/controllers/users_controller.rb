# frozen_string_literal: true

class UsersController < ApplicationController
  include Authenticatable
  include UserManagement


  before_action :authorize_request

  def create
    incoming_role = params[:role].to_sym
    role_int = Constants::Roles::ROLES[incoming_role]

    if role_int.blank?
      return render json: { error: "Unknown role '#{incoming_role}'" }, status: :unprocessable_entity
    end

    if role_int == Constants::Roles::ROLES[:global_admin] || role_int == Constants::Roles::ROLES[:org_admin]
      # Org admins cannot create global admins or other org admins
      return render json: { error: "Org admins cannot create '#{incoming_role}' users" }, status: :forbidden
    end

    allowed_roles = [
      Constants::Roles::ROLES[:teacher],
      Constants::Roles::ROLES[:student]
    ]
    unless allowed_roles.include?(role_int)
      return render json: { error: "Role '#{incoming_role}' not allowed" }, status: :unprocessable_entity
    end

    temp_password = SecureRandom.alphanumeric(8)
    user = current_user.organization.users.new(user_params.merge(
      role: role_int, password: temp_password, password_confirmation: temp_password))
    authorize user

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

  # def bulk_create
  #   incoming_role = params[:role].to_sym
  #   role_int = Constants::Roles::ROLES[incoming_role]

  #   if role_int.blank?
  #     return render json: { error: "Unknown role '#{incoming_role}'" }, status: :unprocessable_entity
  #   end

  #   if role_int == Constants::Roles::ROLES[:global_admin] || role_int == Constants::Roles::ROLES[:org_admin]
  #     return render json: { error: "Org admins cannot create '#{incoming_role}' users" }, status: :forbidden
  #   end

  #   allowed_roles = [
  #     Constants::Roles::ROLES[:teacher],
  #     Constants::Roles::ROLES[:student]
  #   ]

  #   unless allowed_roles.include?(role_int)
  #     return render json: { error: "Role '#{incoming_role}' not allowed" }, status: :unprocessable_entity
  #   end

  #   # Expecting: params[:users] = [ { name: ..., email: ... }, ... ]
  #   users_data = params[:users]
  #   unless users_data.is_a?(Array) && users_data.present?
  #     return render json: { error: "Invalid or missing users data" }, status: :bad_request
  #   end

  #   created_users = []
  #   failed_users = []

  #   users_data.each do |user_data|
  #     temp_password = SecureRandom.alphanumeric(8)

  #     user = current_user.organization.users.new(
  #       user_data.permit(:name, :email).merge(
  #         role: role_int,
  #         password: temp_password,
  #         password_confirmation: temp_password
  #       )
  #     )

  #     begin
  #       authorize user
  #     rescue Pundit::NotAuthorizedError
  #       failed_users << { email: user.email, errors: ['Not authorized to create user'] }
  #       next
  #     end

  #     if user.save
  #       token = JsonWebToken.encode({ user_id: user.id }, 15.minutes.from_now)
  #       reset_url = "#{root_url}reset_password?token=#{token}"

  #       begin
  #         UserMailer.welcome_user(user, temp_password, reset_url).deliver_now
  #       rescue => e
  #         Rails.logger.error("Failed to send welcome email to #{user.email}: #{e.message}")
  #       end

  #       created_users << user
  #     else
  #       failed_users << { email: user.email, errors: user.errors.full_messages }
  #     end
  #   end

  #   render json: {
  #     created: created_users.as_json(only: [:id, :name, :email]),
  #     failed: failed_users
  #   }, status: :multi_status
  # end

  private

  def user_scope
    # Org admins only manage users in their org except global admins
    current_user.organization.users.where.not(id: current_user.id)
  end

  def user_params
    params.permit(:email)
  end
end
