class CoursesController < ApplicationController
  include Authenticatable
  include Pundit

  before_action :set_course, only: [ :show, :update, :destroy ]

  SEMESTER_MAP = {
    "FIRST" => Course::FIRST,
    "SECOND" => Course::SECOND
  }.freeze

  def index
    authorize Course
    render json: policy_scope(Course).order(:semester, :year, :month).reverse
  end

  def show
    render json: @course
  end

  def create
    authorize Course

    incoming_semester = params[:semester]
    semester_int = SEMESTER_MAP[incoming_semester]

    if semester_int.blank?
      return render json: { error: "Unknown semester '#{incoming_semester}'" }, status: :unprocessable_entity
    end

    @course = Course.new(course_params.merge(semester: semester_int))

    if @course.save
      render json: @course, status: :created
    else
      render json: @course.errors, status: :unprocessable_entity
    end
  end

  def update
    if @course.update(course_params)
      render json: @course
    else
      render json: @course.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @course.destroy!
  end

  private
    def set_course
      @course = Course.find(params.expect(:id))
    end

    def course_params
      params.permit(:name, :course_code, :month, :year, :is_completed, :user_id, :organization_id)
    end
end
