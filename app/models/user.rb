class User < ApplicationRecord
  belongs_to :organization, optional: true
  belongs_to :deactivated_by_user, class_name: "User", foreign_key: "deactivated_by_id", optional: true

  has_secure_password
  has_secure_password :security_answer, validations: false
  has_many :enrollments
  has_many :courses, through: :enrollments

  GLOBAL_ADMIN = 0
  ORG_ADMIN = 1
  TEACHER = 2
  STUDENT = 3

  validates :email, presence: true, uniqueness: { scope: :organization_id }
  validates :role, presence: true, inclusion: { in: [ GLOBAL_ADMIN, ORG_ADMIN, TEACHER, STUDENT ] }
  validates :organization, presence: true, unless: -> { role == GLOBAL_ADMIN }
  validates :security_question, presence: true, if: :global_admin?
  validates :security_answer_digest, presence: true, if: :global_admin?

  validate :only_one_global_admin, if: -> { global_admin? }

  def global_admin?
    role == GLOBAL_ADMIN
  end

  def org_admin?
    role == ORG_ADMIN
  end

  def teacher?
    role == TEACHER
  end

  def student?
    role == STUDENT
  end

  def correct_security_answer?(answer)
     authenticate_security_answer(answer)
  end

  private

  def only_one_global_admin
    if User.where(role: GLOBAL_ADMIN).where.not(id: id).exists?
      errors.add(:role, "There can be only one global admin")
    end
  end
end
