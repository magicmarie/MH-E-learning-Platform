# frozen_string_literal: true

class StudentsController < ApplicationController
  include Authenticatable
  include Pundit::Authorization

  before_action :set_student, only: [ :show ]
  before_action :set_course, only: [ :enrolled, :unenrolled ]

  def index
    students = students_in_org.includes(enrollments: :course)
    render json: students, each_serializer: StudentSerializer
  end

  def show
    if @student
      render json: @student, serializer: StudentSerializer
    else
      render_not_found("Student")
    end
  end

  def enrolled
    students = students_in_org.joins(:enrollments)
                              .where(enrollments: { course_id: @course.id })
                              .distinct

    render json: students, each_serializer: StudentSerializer
  end

  def unenrolled
    students = students_in_org.where.not(id: @course.enrollments.select(:user_id))

    render json: students, each_serializer: StudentSerializer
  end

  private

  def set_student
    @student = students_in_org.find_by(id: params[:id])
  end

  def set_course
    @course = Course.find_by(id: params[:course_id], organization: current_user.organization)
    render_not_found("Course") unless @course
  end

  def students_in_org
    User.students_in_organization(current_user.organization)
  end

  def render_not_found(resource)
    render json: { error: "#{resource} not found" }, status: :not_found
  end
end
