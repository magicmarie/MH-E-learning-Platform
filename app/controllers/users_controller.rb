# frozen_string_literal: true

# Handles user management operations for organization admins and global admins
#
# This controller provides endpoints for:
# - Creating individual users
# - Bulk creating users from CSV files
# - User activation/deactivation
class UsersController < ApplicationController
  require "csv"

  include Authenticatable
  include UserManagement

  # POST /users
  # Creates a new user within the current user's organization
  #
  # @param email [String] User's email address
  # @param role [Symbol] User role (:teacher, :student)
  def create
    user = current_user.organization.users.new(email: params[:email])
    authorize user

    result = Users::CreateUser.run(
      current_user: current_user,
      email: params[:email],
      incoming_role: params[:role].to_sym
    )

    if result.valid?
      render json: result.result, status: :created
    else
      render json: { errors: result.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def bulk_create
    authorize User, :bulk_create?

    result = Users::BulkCreateUsers.run(
      current_user: current_user,
      file: params[:file],
      incoming_role: params[:role].to_sym
    )

    if result.valid?
      render json: {
        created: ActiveModelSerializers::SerializableResource.new(result.result[:created]),
        failed: result.result[:failed]
      }, status: :multi_status
    else
      render json: { errors: result.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private
end
