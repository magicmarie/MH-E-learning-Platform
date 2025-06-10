# app/controllers/enrollments_controller.rb
class EnrollmentsController < ApplicationController
  include Authenticatable
  include Pundit

  before_action :set_course
  before_action :set_enrollment, only: [ :show, :update, :destroy ]

  def index
    @enrollments = policy_scope(@course.enrollments)
    render json: @enrollments
  end

  def show
    authorize @enrollment
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
    authorize @enrollment
    if @enrollment.update(enrollment_params)
      render json: @enrollment
    else
      render json: { errors: @enrollment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @enrollment
    @enrollment.destroy
  end

  def bulk_create
    course = Course.find(params[:course_id])
    authorize course, :update?

    user_ids = params[:user_ids] || []
    status = params[:status] || nil

    created = []
    failed = []

    users = User.where(id: user_ids).select(&:student?)

    users.each do |user|
      enrollment = Enrollment.find_or_initialize_by(user: user, course: course)
      enrollment.status = status if status.present?

      if enrollment.save
        created << enrollment
      else
        failed << { user_id: user.id, errors: enrollment.errors.full_messages }
      end
    end

    render json: {
      created: created.map { |e| EnrollmentSerializer.new(e) },
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

  def enrollment_params
    params.permit(:user_id, :course_id, :status, :grade)
  end
end
