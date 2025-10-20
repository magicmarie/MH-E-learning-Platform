# frozen_string_literal: true

class Admin::OrganizationsController < ApplicationController
  include Authenticatable
  include Pundit::Authorization

  before_action :set_organization, only: %i[show update destroy]
  before_action :authorize_organization, only: %i[show update destroy]
  before_action :authorize_collection, only: %i[index_stats create]

  def create
    org = Organization.new(org_params)
    if org.save
      render json: org, status: :created
    else
      render json: { errors: org.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def show
    render json: @organization
  end

  def update
    if @organization.update(org_params)
      render json: @organization
    else
      render json: { errors: @organization.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @organization.users.update_all(active: false, deactivated_at: Time.current)
    render json: { message: "Organization and users deactivated" }

    # If you want to permanently delete instead of deactivate, uncomment below:
    # @organization.destroy
    # render json: { message: "Organization and users deleted" }
  end

  def index_stats
    stats = Organization.all.map do |org|
      {
        organization_name: org.name,
        admins_count: org.users.where(role: Constants::Roles::ROLES[:org_admin]).count,
        teachers_count: org.users.where(role: Constants::Roles::ROLES[:teacher]).count,
        students_count: org.users.where(role: Constants::Roles::ROLES[:student]).count
      }
    end

    render json: stats
  end

  private

  def set_organization
    @organization = Organization.find_by(id: params[:id])
    render json: { error: "Not found" }, status: :not_found unless @organization
  end

  def authorize_organization
    authorize @organization if @organization
  end

  def authorize_collection
    authorize Organization
  end

  def org_params
    params.permit(:name, :organization_code, settings: {})
  end
end
