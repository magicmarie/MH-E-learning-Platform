# frozen_string_literal: true

class AssignmentsController < ApplicationController
  include Authenticatable
  include Pundit::Authorization

  before_action :set_course
  before_action :set_assignment, only: [ :show, :update, :destroy ]
  before_action :authorize_assignment, only: [ :create, :update, :destroy ]

  def index
    @assignments = policy_scope(@course.assignments).includes(:assessments, files_attachments: :blob)
    render json: @assignments
  end

  def show
    render json: @assignment
  end

  def create
    @assignment = @course.assignments.build(assignment_params)
    if @assignment.save
      # Automatically create assessments for all enrolled students
      @assignment.create_assessments_for_enrollments
      render json: @assignment, status: :created
    else
      render json: { errors: @assignment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @assignment.update(assignment_params)
      render json: @assignment
    else
      render json: { errors: @assignment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @assignment.destroy
    head :no_content
  end

  private

  def set_course
    @course = Course.find(params[:course_id])
  end

  def set_assignment
    @assignment = @course.assignments.includes(:assessments, files_attachments: :blob).find(params[:id])
  end

  def authorize_assignment
    authorize @assignment || Assignment.new(course: @course)
  end

  def assignment_params
    params.permit(:title, :assignment_type, :max_score, :deadline, files: [])
  end
end
