# frozen_string_literal: true

class Admin::OrganizationsController < ApplicationController
  include Authenticatable
  include Pundit

  def index
    authorize Organization
    render json: Organization.all
  end

  def create
    authorize Organization
    org = Organization.new(org_params)

    if org.save
      render json: org, status: :created
    else
      render json: { errors: org.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def show
    org = Organization.find_by(id: params[:id])
    return render json: { error: "Not found" }, status: :not_found unless org

    authorize org
    render json: org
  end

  def update
    org = Organization.find_by(id: params[:id])
    return render json: { error: "Not found" }, status: :not_found unless org

    authorize org

    if org.update(org_params)
      render json: org
    else
      render json: { errors: org.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    authorize Organization
    org = Organization.find_by(id: params[:id])
    return render json: { error: "Organization not found" }, status: :not_found unless org

    # Soft-delete users or destroy them depending on our needs
    org.users.update_all(active: false, deactivated_at: Time.current)
    render json: { message: "Organization and users deactivated" }

    # org.destroy
    # render json: { message: "Organization and users deleted" }
  end

  private

  def org_params
    params.permit(:name, :organization_code)
  end
end
