# frozen_string_literal: true

class OrganizationsController < ApplicationController
  include Authenticatable
  include Pundit::Authorization

  before_action :authorize_request, only: [ :show, :update ]
  before_action :set_organization, only: [ :show, :update ]
  before_action :authorize_organization, only: [ :show, :update ]

  def index
    authorize Organization
    organizations = policy_scope(Organization)
    render json: organizations
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

  def search
    query = params[:q].to_s.strip.downcase

    if query.length < 3
      return render json: { errors: [ "Query too short" ] }, status: :bad_request
    end

    matches = policy_scope(Organization)
      .where("LOWER(organization_code) LIKE ?", "#{query}%")
      .select(:id, :name, :organization_code)
      .limit(8)

    render json: matches
  end

  private

  def set_organization
    @organization = current_user&.organization
    render json: { errors: [ "Organization not found" ] }, status: :not_found unless @organization
  end

  def authorize_organization
    authorize @organization
  end

  def org_params
    params.permit(:name, :organization_code, :settings)
  end
end
