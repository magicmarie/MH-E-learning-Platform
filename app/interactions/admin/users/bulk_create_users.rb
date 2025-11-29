# frozen_string_literal: true

module Admin
  module Users
    class BulkCreateUsers < ActiveInteraction::Base
      object :current_user, class: User
      array :users_data, default: []
      symbol :incoming_role
      integer :organization_id

      def execute
        role_int = Constants::Roles::ROLES[incoming_role]

        if role_int == Constants::Roles::ROLES[:global_admin]
          errors.add(:base, "Cannot create global_admin")
          return nil
        end

        unless allowed_roles.include?(role_int)
          errors.add(:base, "Role '#{incoming_role}' not allowed")
          return nil
        end

        organization = Organization.find_by(id: organization_id)
        unless organization
          errors.add(:base, "Organization not found")
          return nil
        end

        created_users = []
        failed_users = []

        users_data.each do |user_data|
          temp_password = SecureRandom.alphanumeric(8)

          user = organization.users.new(
            email: user_data[:email],
            role: role_int,
            password: temp_password,
            password_confirmation: temp_password
          )

          begin
            ApplicationController.new.send(:authorize, user)
          rescue Pundit::NotAuthorizedError
            failed_users << { email: user.email, errors: [ "Not authorized to create user" ] }
            next
          end

          if user.save
            send_welcome_email(user, temp_password)
            created_users << user
          else
            failed_users << { email: user.email, errors: user.errors.full_messages }
          end
        end

        { created: created_users, failed: failed_users }
      end

      private

      def allowed_roles
        [
          Constants::Roles::ROLES[:org_admin],
          Constants::Roles::ROLES[:teacher],
          Constants::Roles::ROLES[:student]
        ]
      end

      def send_welcome_email(user, temp_password)
        token = JsonWebToken.encode({ user_id: user.id }, 15.minutes.from_now)
        reset_url = "http://localhost:5173/reset_password?token=#{token}"
        UserMailer.welcome_user(user, temp_password, reset_url).deliver_now
      rescue => e
        Rails.logger.error("Failed to send welcome email to #{user.email}: #{e.message}")
      end
    end
  end
end
