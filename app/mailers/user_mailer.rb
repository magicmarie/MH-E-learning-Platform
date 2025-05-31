# frozen_string_literal: true

class UserMailer < ApplicationMailer
    default from: "no-reply@example.com"

    def welcome_user(user, org_code, temp_password)
      @user = user
      @org_code = org_code
      @temp_password = temp_password

      mail(to: @user.email, subject: "Welcome to the Platform!")
    end
end
