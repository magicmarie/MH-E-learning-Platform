# frozen_string_literal: true

class UserMailer < ApplicationMailer
    default from: "natukunda162@gmail.com"

    def welcome_user(user, org_code, temp_password, reset_password_url)
      @user_email = user.email
      @temp_password = temp_password
      @org_code = user.organization&.organization_code
      @org_name = user.organization&.name
      @reset_password_url = reset_password_url

      mail(to: @user.email, subject: "Welcome to the MH-ELP Platform!")
    end
end
