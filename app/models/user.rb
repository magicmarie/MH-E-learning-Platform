class User < ApplicationRecord
  belongs_to :organization, optional: true
  belongs_to :deactivated_by_user, class_name: "User", foreign_key: "deactivated_by_id", optional: true
  belongs_to :activated_by_user, class_name: "User", foreign_key: "activated_by_id", optional: true

  has_secure_password
  has_secure_password :security_answer, validations: false
  has_many :enrollments
  has_many :courses, through: :enrollments
  has_one :user_profile, dependent: :destroy


  validates :email, presence: true, uniqueness: { scope: :organization_id }
  validates :password, presence: true, length: { minimum: 8 }, allow_nil: true
  validates :role, presence: true, inclusion: { in: [
    Constants::Roles::ROLES[:global_admin],
    Constants::Roles::ROLES[:org_admin],
    Constants::Roles::ROLES[:teacher],
    Constants::Roles::ROLES[:student]
    ] }
  validates :organization, presence: true, unless: -> { role == Constants::Roles::ROLES[:global_admin] }
  validates :security_question, presence: true, if: :global_admin?
  validates :security_answer_digest, presence: true, if: :global_admin?

  validate :only_one_global_admin, if: -> { global_admin? }

  after_create :create_default_profile, unless: :global_admin?
  before_validation :normalize_email

  scope :global_admins, -> { where(role: Constants::Roles::ROLES[:global_admin]) }
  scope :students_in_organization, ->(organization) {
    where(role: Constants::Roles::ROLES[:student], organization: organization)
  }

  def normalize_email
    self.email = email.strip.downcase if email.present?
  end

  def global_admin?
    role == Constants::Roles::ROLES[:global_admin]
  end

  def org_admin?
    role == Constants::Roles::ROLES[:org_admin]
  end

  def teacher?
    role == Constants::Roles::ROLES[:teacher]
  end

  def student?
    role == Constants::Roles::ROLES[:student]
  end

  def correct_security_answer?(answer)
     authenticate_security_answer(answer)
  end

  def create_default_profile
    create_user_profile!
  end

  def generate_reset_token(expiration = 1.hour.from_now)
    JsonWebToken.encode({ user_id: id, iat: Time.current.to_i }, expiration)
  end

  # Check if a token is still valid (not reused)
  def reset_token_used_after?(issued_at)
    reset_password_token_used_at.present? && reset_password_token_used_at > issued_at.to_time
  end

  # Mark the token as used
  def mark_reset_token_used!
    update!(reset_password_token_used_at: Time.current)
  end

  private

  def only_one_global_admin
    if User.where(role: Constants::Roles::ROLES[:global_admin]).where.not(id: id).exists?
      errors.add(:role, "There can be only one global admin")
    end
  end
end
