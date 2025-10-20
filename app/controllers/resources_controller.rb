# frozen_string_literal: true

class ResourcesController < ApplicationController
  include Authenticatable
  include Pundit::Authorization

  before_action :set_course
  before_action :set_resource, only: [ :show, :update, :destroy ]
  before_action :authorize_resource, only: [ :show, :update, :destroy, :create ]

  def index
    @resources = policy_scope(@course.resources)
    render json: @resources
  end

  def show
    render json: @resource
  end

  def create
    @resource = @course.resources.build(resource_params)
    if @resource.save
      render json: @resource, status: :created
    else
      render json: { errors: @resource.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @resource.update(resource_params)
      render json: @resource
    else
      render json: { errors: @resource.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @resource.destroy
    head :no_content
  end

  private

  def set_course
    @course = Course.find(params[:course_id])
  end

  def set_resource
    @resource = @course.resources.find(params[:id])
  end

  def authorize_resource
    authorize @resource || Resource.new(course: @course)
  end

  def resource_params
    params.permit(:title, :description, :file)
  end
end
