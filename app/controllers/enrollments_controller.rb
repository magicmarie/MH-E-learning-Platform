# frozen_string_literal: true

class EnrollmentsController < ApplicationController
  include Authenticatable
  include Pundit::Authorization

  before_action :set_course
  before_action :set_enrollment, only: [ :show, :update, :destroy ]
  before_action :authorize_enrollment, only: [ :show, :update, :destroy ]

  def index
    @enrollments = policy_scope(@course.enrollments)
    render json: @enrollments
  end

  def show
    render json: @enrollment
  end

  def create
    @enrollment = @course.enrollments.new(enrollment_params)
    authorize @enrollment

    if @enrollment.save
      render json: @enrollment, status: :created
    else
      render json: { errors: @enrollment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @enrollment.update(enrollment_params)
      render json: @enrollment
    else
      render json: { errors: @enrollment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @enrollment.destroy
    head :no_content
  end

  def bulk_create
    authorize @course, :update?

    user_ids = params[:user_ids] || []
    status = params[:status]

    users = User.where(
      id: user_ids,
      role: Constants::Roles::ROLES[:student],
      organization_id: @course.organization_id)
    created, failed = [], []

    users.find_each do |user|
      enrollment = Enrollment.find_or_initialize_by(user: user, course: @course)
      enrollment.status = status if status.present?

      if enrollment.save
        created << enrollment
      else
        failed << { user_id: user.id, errors: enrollment.errors.full_messages }
      end
    end

    render json: {
      created: ActiveModelSerializers::SerializableResource.new(created, each_serializer: EnrollmentSerializer),
      failed: failed
    }, status: :created
  end

  private

  def set_course
    @course = Course.find(params[:course_id])
  end

  def set_enrollment
    @enrollment = @course.enrollments.find(params[:id])
  end

  def authorize_enrollment
    authorize @enrollment
  end

  def enrollment_params
    params.permit(:user_id, :course_id, :status, :grade)
  end
end
