# frozen_string_literal: true

# Manages course operations for teachers, org admins, and global admins
#
# This controller handles:
# - Course CRUD operations
# - Course listing with filtering and eager loading
# - Semester and enrollment management
class CoursesController < ApplicationController
  include Authenticatable
  include Pundit::Authorization
  include Constants::Semesters

  before_action :set_course, only: [ :show, :update, :destroy ]
  before_action :authorize_course, only: [ :show, :update, :destroy ]

  # GET /courses
  # Lists all courses accessible to the current user
  # Includes associations to prevent N+1 queries
  def index
    authorize Course
    courses = policy_scope(Course)
      .includes(:user, :organization, :enrollments, :assignments)
      .order(year: :desc, semester: :desc, month: :desc)
    render json: courses
  end

  def show
    render json: @course
  end

  # POST /courses
  # Creates a new course
  #
  # @param name [String] Course name
  # @param course_code [String] Unique course code
  # @param semester [String] Semester ('first' or 'second')
  # @param month [Integer] Month (1-12)
  # @param year [Integer] Year
  def create
    authorize Course

    course_attributes = course_params.merge(
      user_id: current_user.id,
      organization_id: current_user.organization_id
    )

    @course = Course.new(course_attributes)

    if @course.save
      render json: @course, status: :created
    else
      raise Errors::ValidationError.new("Course creation failed", errors: @course.errors.full_messages)
    end
  end

  # PATCH /courses/:id
  # Updates an existing course
  def update
    if @course.update(course_params)
      render json: @course
    else
      raise Errors::ValidationError.new("Course update failed", errors: @course.errors.full_messages)
    end
  end

  # DELETE /courses/:id
  # Deletes a course
  def destroy
    @course.destroy!
    head :no_content
  end

  private

  def set_course
    @course = Course.find(params[:id])
  end

  def authorize_course
    authorize @course
  end

  def course_params
    base_params = [ :name, :course_code, :month, :year, :is_completed ]
    base_params += [ :user_id, :organization_id ] if current_user.global_admin?
    params.permit(*base_params)
  end

  # Converts semester parameter to integer value
  #
  # @param param [String, Symbol] The semester parameter (:first or :second)
  # @return [Integer, nil] The semester integer or nil if invalid
  def semester_param_to_int(param)
    return nil unless param

    key = param.to_sym
    semester_int = SEMESTERS[key]

    unless semester_int
      render_error(
        message: "Validation failed",
        status: :unprocessable_entity,
        errors: [ "Unknown semester '#{param}'. Valid options: #{SEMESTERS.keys.join(', ')}" ]
      )
      return nil
    end

    semester_int
  end
end
