# frozen_string_literal: true

class ResourcesController < ApplicationController
  include Authenticatable
  include Pundit

  before_action :authorize_request
  before_action :set_resource, only: [ :show, :update, :destroy ]

  def index
    @resources = policy_scope(Resource)
    render json: @resources
  end

  def show
    authorize @resource
    render json: @resource
  end

  def create
    course = Course.find(params[:course_id])
    @resource = Resource.new(resource_params)
    @resource.course = course
    authorize @resource

    if @resource.save
      render json: @resource, status: :created
    else
      render json: { errors: @resource.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    authorize @resource
    if @resource.update(resource_params)
      render json: @resource
    else
      render json: { errors: @resource.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @resource
    @resource.destroy
    head :no_content
  end

  private

  def set_resource
    @resource = Resource.find(params[:id])
  end

  def resource_params
    params.permit(:course_id, :title, :description, files: [])
  end
end
