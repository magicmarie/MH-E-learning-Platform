class Enrollment < ApplicationRecord
  belongs_to :user
  belongs_to :course
  has_many :assessments, dependent: :destroy

  after_initialize :set_defaults, if: :new_record?

  validates :status, presence: false, inclusion: { in: [
    Constants::EnrollmentStatus::STATUSES[:dropped],
    Constants::EnrollmentStatus::STATUSES[:active],
    Constants::EnrollmentStatus::STATUSES[:passed],
    Constants::EnrollmentStatus::STATUSES[:failed]
  ] }

  def total_score
    assessments.sum(:score)
  end

  def set_defaults
    self.status ||= Constants::EnrollmentStatus::STATUSES[:active]
    self.grade ||= nil
  end
end
