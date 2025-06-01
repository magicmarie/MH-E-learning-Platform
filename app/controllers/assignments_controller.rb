# app/controllers/assignments_controller.rb
class AssignmentsController < ApplicationController
  before_action :set_course
  before_action :set_assignment, only: [ :show, :update, :destroy ]
  before_action :authorize_assignment, only: [ :create, :update, :destroy ]

  def index
    @assignments = policy_scope(@course.assignments)
    render json: @assignments
  end

  def show
    authorize @assignment
    render json: @assignment
  end

  def create
    @assignment = @course.assignments.build(assignment_params)
    authorize @assignment

    if @assignment.save
      enrollments = @course.enrollments.includes(:user)
      enrollments.each do |enrollment|
        Assessment.create!(assignment: @assignment, enrollment: enrollment, score: 0)
      end
      render json: @assignment, status: :created
    else
      render json: { errors: @assignment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    authorize @assignment

    if @assignment.update(assignment_params)
      render json: @assignment
    else
      render json: { errors: @assignment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @assignment
    @assignment.destroy
    head :no_content
  end

  private

  def set_course
    @course = Course.find(params[:course_id])
  end

  def set_assignment
    @assignment = @course.assignments.find(params[:id])
  end

  def authorize_assignment
    authorize @assignment || Assignment.new(course: @course)
  end

  def assignment_params
    params.require(:assignment).permit(:title, :assignment_type, :max_score, :deadline)
  end
end
