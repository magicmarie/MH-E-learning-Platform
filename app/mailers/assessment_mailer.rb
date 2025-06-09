# frozen_string_literal: true

class AssessmentMailer < ApplicationMailer
    default from: "natukunda162@gmail.com"

    def welcome_user(assessment, user_email)
      @assessment_type = assessment.assignment.assignment_type
      @user_email = user_email
      @updated_at = assessment.updated_at.strftime("%B %d, %Y at %I:%M %p")
      @score = assessment.score

      mail(to: @user.email, subject: "Welcome to the Platform!")
    end
end
