# frozen_string_literal: true

class CoursesController < ApplicationController
  include Authenticatable
  include Pundit::Authorization

  before_action :set_course, only: [ :show, :update, :destroy ]
  before_action :authorize_course, only: [ :show, :update, :destroy ]

  def index
    authorize Course
    courses = policy_scope(Course).order(year: :desc, semester: :desc, month: :desc)
    render json: courses
  end

  def show
    render json: @course
  end

  def create
    authorize Course

    semester_int = semester_param_to_int(params[:semester])
    return unless semester_int

    @course = Course.new(course_params.merge(
      semester: semester_int,
      user_id: current_user.id,
      organization_id: current_user.organization_id
    ))

    if @course.save
      render json: @course, status: :created
    else
      render json: { errors: @course.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    semester_int = semester_param_to_int(params[:semester])
    return unless semester_int

    if @course.update(course_params.merge(semester: semester_int))
      render json: @course
    else
      render json: { errors: @course.errors.full_messages }, status: :unprocessable_entity
    end
  end

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
    base_params = [:name, :course_code, :month, :year, :is_completed]
    base_params += [:user_id, :organization_id] if current_user.global_admin?
    params.permit(*base_params)
  end

  def semester_param_to_int(param)
    return nil unless param

    key = param.to_sym
    semester_int = Constants::Semesters::SEMESTERS[key]

    unless semester_int
      render json: { errors: ["Unknown semester '#{param}'"] }, status: :unprocessable_entity
      return nil
    end

    semester_int
  end
end
