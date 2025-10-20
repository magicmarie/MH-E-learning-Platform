# frozen_string_literal: true

class Admin::UsersController < ApplicationController
  include Authenticatable
  include UserManagement

  def create
    authorize User

    result = ::Admin::Users::CreateUser.run(
      current_user: current_user,
      email: params[:email],
      incoming_role: params[:role].to_sym,
      organization_id: params[:organization_id]
    )

    if result.valid?
      render json: result.result, status: :created
    else
      render json: { errors: result.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def bulk_create
    authorize User, :bulk_create?

    result = ::Admin::Users::BulkCreateUsers.run(
      current_user: current_user,
      incoming_role: params[:role].to_sym,
      organization_id: params[:organization_id],
      users_data: params[:users].map(&:to_unsafe_h)
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
end
