# frozen_string_literal: true

class OrganizationsController < ApplicationController
  include Authenticatable
  include Pundit

  before_action :authorize_request
  before_action :set_organization

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

  private

  def set_organization
    @organization = current_user&.organization
  end

  def org_params
    params.permit(:name)
  end
end
