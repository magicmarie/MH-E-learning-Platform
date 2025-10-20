# frozen_string_literal: true

class AssessmentsController < ApplicationController
  include Authenticatable

  before_action :set_assessment, only: [:show, :update]
  before_action :authorize_assessment

  def index
    @assessments = policy_scope(Assessment)
    render json: @assessments
  end

  def show
    render json: @assessment
  end

  def update
    # Pass current user to the model
    @assessment.current_user = @current_user

    if @assessment.update(assessment_params)
      render json: @assessment
    else
      render json: { errors: @assessment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_assessment
    @assessment = Assessment.find(params[:id])
  end

  def authorize_assessment
    authorize @assessment
  end

  def assessment_params
    if @current_user.student?
      params.require(:assessment).permit(:score, files: [])
    else
      params.require(:assessment).permit(:score, :enrollment_id, :assignment_id)
    end
  end
end
