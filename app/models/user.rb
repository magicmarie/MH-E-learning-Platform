# Represents a user in the learning management system
#
# Users can have one of four roles: global_admin, org_admin, teacher, or student.
# All users except global admins must belong to an organization.
class User < ApplicationRecord
  include Constants::Roles

  belongs_to :organization, optional: true
  belongs_to :deactivated_by_user, class_name: "User", foreign_key: "deactivated_by_id", optional: true
  belongs_to :activated_by_user, class_name: "User", foreign_key: "activated_by_id", optional: true

  has_secure_password
  has_secure_password :security_answer, validations: false
  has_many :enrollments
  has_many :courses, through: :enrollments
  has_one :user_profile, dependent: :destroy


  validates :email, presence: true, uniqueness: { scope: :organization_id }
  validates :password, length: { minimum: AuthConfig::MIN_PASSWORD_LENGTH }, if: :password_required?
  validates :role, presence: true, inclusion: { in: ROLES.values }
  validates :organization, presence: true, unless: :global_admin?
  validates :security_question, presence: true, if: :global_admin?
  validates :security_answer_digest, presence: true, if: :global_admin?

  validate :only_one_global_admin, if: :global_admin?
  validate :organization_id_matches_organization, if: -> { organization_id.present? && organization.present? }

  after_create :create_default_profile, unless: :global_admin?
  before_validation :normalize_email

  scope :global_admins, -> { where(role: ROLES[:global_admin]) }
  scope :students_in_organization, ->(organization) {
    where(role: ROLES[:student], organization: organization)
  }

  # Normalizes email to lowercase and removes whitespace
  def normalize_email
    self.email = email.strip.downcase if email.present?
  end

  # Role checker methods
  def global_admin?
    role == ROLES[:global_admin]
  end

  def org_admin?
    role == ROLES[:org_admin]
  end

  def teacher?
    role == ROLES[:teacher]
  end

  def student?
    role == ROLES[:student]
  end

  # Returns the human-readable role name
  #
  # @return [Symbol] The role name (:global_admin, :org_admin, :teacher, :student)
  def role_name
    ROLE_NAMES[role]
  end

  # Verifies if the provided security answer is correct
  #
  # @param answer [String] The security answer to verify
  # @return [User, false] Returns user if correct, false otherwise
  def correct_security_answer?(answer)
     authenticate_security_answer(answer)
  end

  # Creates default user profile after user creation
  def create_default_profile
    create_user_profile!
  end

  # Generates a password reset token
  #
  # @param expiration [ActiveSupport::TimeWithZone] Token expiration time
  # @return [String] Encoded JWT token
  def generate_reset_token(expiration = AuthConfig::RESET_TOKEN_EXPIRY.from_now)
    JsonWebToken.encode({ user_id: id, iat: Time.current.to_i }, expiration)
  end

  # Checks if a reset token was used after it was issued
  #
  # @param issued_at [Time] When the token was issued
  # @return [Boolean] True if token was already used
  def reset_token_used_after?(issued_at)
    reset_password_token_used_at.present? && reset_password_token_used_at > issued_at.to_time
  end

  # Marks the reset token as used to prevent reuse
  def mark_reset_token_used!
    update!(reset_password_token_used_at: Time.current)
  end

  private

  # Validates password is required only during create or when password is being changed
  def password_required?
    password_digest.blank? || password.present?
  end

  # Ensures only one global admin exists in the system
  def only_one_global_admin
    if User.where(role: ROLES[:global_admin]).where.not(id: id).exists?
      errors.add(:role, "There can be only one global admin")
    end
  end

  # Ensures organization_id matches the organization association
  def organization_id_matches_organization
    if organization_id != organization.id
      errors.add(:organization_id, "must match the organization association")
    end
  end
end
