# frozen_string_literal: true

module Users
  # Creates a new user within an organization
  #
  # This interaction:
  # - Validates the incoming role is permitted
  # - Prevents org admins from creating other admins
  # - Generates a secure temporary password
  # - Sends a welcome email with password reset link
  #
  # @example
  #   result = Users::CreateUser.run(
  #     current_user: admin,
  #     email: 'teacher@school.com',
  #     incoming_role: :teacher
  #   )
  class CreateUser < ActiveInteraction::Base
    include Constants::Roles

    object :current_user, class: User
    string :email
    symbol :incoming_role

    validates :incoming_role, inclusion: { in: ROLES.keys }

    def execute
      role_int = ROLES[incoming_role]

      if disallowed_admin_creation?(role_int)
        errors.add(:base, "Org admins cannot create '#{incoming_role}' users")
        return nil
      end

      unless allowed_roles.include?(role_int)
        errors.add(:base, "Role '#{incoming_role}' not allowed")
        return nil
      end

      temp_password = SecureRandom.alphanumeric(AuthConfig::TEMP_PASSWORD_LENGTH)

      user = current_user.organization.users.new(
        email: email,
        role: role_int,
        password: temp_password,
        password_confirmation: temp_password
      )

      if user.save
        send_welcome_email(user, temp_password)
        user
      else
        errors.merge!(user.errors)
        nil
      end
    end

    private

    def allowed_roles
      [ROLES[:teacher], ROLES[:student]]
    end

    def disallowed_admin_creation?(role_int)
      [ROLES[:global_admin], ROLES[:org_admin]].include?(role_int)
    end

    def send_welcome_email(user, temp_password)
      token = JsonWebToken.encode({ user_id: user.id }, AuthConfig::WELCOME_TOKEN_EXPIRY.from_now)
      reset_url = "#{Rails.application.routes.url_helpers.root_url}reset_password?token=#{token}"

      UserMailer.welcome_user(user, temp_password, reset_url).deliver_now
    rescue => e
      Rails.logger.error("Failed to send welcome email to #{user.email}: #{e.message}")
    end
  end
end
