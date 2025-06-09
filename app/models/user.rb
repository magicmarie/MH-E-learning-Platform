class User < ApplicationRecord
  belongs_to :organization, optional: true
  belongs_to :deactivated_by_user, class_name: "User", foreign_key: "deactivated_by_id", optional: true

  has_secure_password
  has_secure_password :security_answer, validations: false
  has_many :enrollments
  has_many :courses, through: :enrollments

  validates :email, presence: true, uniqueness: { scope: :organization_id }
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

  scope :global_admins, -> { where(role: Constants::Roles::ROLES[:global_admin]) }

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

  private

  def only_one_global_admin
    if User.where(role: Constants::Roles::ROLES[:global_admin]).where.not(id: id).exists?
      errors.add(:role, "There can be only one global admin")
    end
  end
end
