# app/controllers/admin/users_controller.rb

class Admin::UsersController < ApplicationController
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
    authorize User
    incoming_role = params[:role].to_s
    role_int = ROLE_MAP[incoming_role]

    if role_int.nil?
      return render json: { error: "Unknown role '#{incoming_role}'" }, status: :unprocessable_entity
    end

    if role_int == User::GLOBAL_ADMIN
      return render json: { error: "Cannot create global_admin" }, status: :forbidden
    end

    # Global admins can only create org_admins, teachers, and students
    allowed_roles = [ User::ORG_ADMIN, User::TEACHER, User::STUDENT ]
    unless allowed_roles.include?(role_int)
      return render json: { error: "Role #{incoming_role} not allowed" }, status: :unprocessable_entity
    end

    # Global admins must provide organization_id
    organization_id = params[:organization_id]
    organization = Organization.find_by(id: organization_id)

    unless organization
      return render json: { error: "Organization not found" }, status: :not_found
    end

    user = organization.users.new(user_params.merge(role: role_int))

    if user.save
      render json: user, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  # Global admins can see all users
  def user_scope
    User.all
  end

  def user_params
    params.permit(:email, :password, :password_confirmation)
  end
end
