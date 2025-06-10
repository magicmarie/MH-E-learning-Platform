# frozen_string_literal: true

class StudentsController < ApplicationController
  include Authenticatable
  include Pundit

  before_action :authorize_request
  before_action :set_student, only: [ :show ]

  def index
    students = User.where(role: Constants::Roles::ROLES[:student], organization: current_user.organization)
                    .includes(enrollments: :course)
    render json: students
  end

  def show
    if @student
      render json: @student, serializer: StudentSerializer
    else
      render json: { error: "Student not found" }, status: :not_found
    end
  end

  private
  def set_student
    @student = User.find_by(id: params[:id], role: Constants::Roles::ROLES[:student], organization: current_user.organization)
  end
end
