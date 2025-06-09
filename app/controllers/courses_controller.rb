class CoursesController < ApplicationController
  include Authenticatable
  include Pundit

  before_action :set_course, only: [ :show, :update, :destroy ]

  def index
    authorize Course
    render json: policy_scope(Course).order(:semester, :year, :month).reverse
  end

  def show
    render json: @course
  end

  def create
    authorize Course

    incoming_semester = params[:semester].to_sym
    semester_int = Constants::Semesters::SEMESTERS[incoming_semester]

    if semester_int.blank?
      return render json: { error: "Unknown semester '#{incoming_semester}'" }, status: :unprocessable_entity
    end

    user = current_user
    organization_id = user.organization_id
    @course = Course.new(course_params.merge(semester: semester_int, user_id: user.id, organization_id: organization_id))

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
      params.permit(:name, :course_code, :month, :year, :is_completed, :semester)
    end
end
