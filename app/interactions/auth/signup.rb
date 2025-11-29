module Auth
  class Signup < ActiveInteraction::Base
    include Constants::Roles

    string :email, :password
    integer :organization_id
    string :role, default: "student"

    # Security: Public signup allows org_admin, teacher, and student roles
    # Global admin role is blocked as it already exists in the database
    validates :role, inclusion: {
      in: %w[org_admin teacher student],
      message: "must be org_admin, teacher, or student"
    }

    def execute
      organization = Organization.find_by(id: organization_id)
      unless organization
        errors.add(:base, "Organization not found")
        return nil
      end

      role_integer = ROLES[role.to_sym]
      unless role_integer
        errors.add(:role, "Invalid role: #{role}")
        return nil
      end

      # Prevent global_admin creation via signup
      if role_integer == ROLES[:global_admin]
        errors.add(:role, "Cannot create global admin through signup")
        return nil
      end

      user = organization.users.new(
        email: email,
        password: password,
        role: role_integer
      )

      if user.save
        token = JsonWebToken.encode(user_id: user.id)
        {
          token: token,
          user: UserSerializer.new(user).as_json
        }
      else
        errors.merge!(user.errors)
        nil
      end
    end
  end
end
