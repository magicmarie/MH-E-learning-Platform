class CoursesController < ApplicationController
  include Pundit

  before_action :set_course, only: [ :show, :update, :destroy ]

  def index
    authorize Course
    render json: Course.all
  end

  def show
    render json: @course
  end

  def create
    @course = Course.new(course_params)

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
      params.expect(course: [ :name, :course_code, :semester, :month, :year, :is_completed, :user_id, :organization_id ])
    end
end
