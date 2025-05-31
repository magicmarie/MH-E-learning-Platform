# frozen_string_literal: true

class OrganizationsController < ApplicationController
  include Authenticatable
  include Pundit

  before_action :authorize_request, only: [ :show, :update ]
  before_action :set_organization, only: [ :show, :update ]

  def show
    if @organization.nil?

      render json: { error: "Organization not found" }, status: :not_found
    else
      authorize @organization
      render json: @organization
    end
  end

  def update
    if @organization.nil?
      render json: { error: "Organization not found" }, status: :not_found
    else
      authorize @organization

      if @organization.update(org_params)
        render json: @organization
      else
        render json: { errors: @organization.errors.full_messages }, status: :unprocessable_entity
      end
    end
  end

  def search
    query = params[:q].to_s.strip

    if query.length < 3
      return render json: { error: "Query too short" }, status: :bad_request
    end

    matches = Organization
      .where("LOWER(organization_code) LIKE ?", "#{query}%")
      .select(:id, :name, :organization_code)
      .limit(8)

    render json: matches
  end

  private

  def set_organization
    @organization = current_user&.organization
  end

  def org_params
    params.permit(:name)
  end
end
