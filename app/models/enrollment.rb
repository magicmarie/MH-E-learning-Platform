class Enrollment < ApplicationRecord
  belongs_to :user
  belongs_to :course
  has_many :assessments, dependent: :destroy

  validates :status, presence: true, inclusion: { in: [
    Constants::EnrollmentStatus::STATUSES[:dropped],
    Constants::EnrollmentStatus::STATUSES[:active],
    Constants::EnrollmentStatus::STATUSES[:passed],
    Constants::EnrollmentStatus::STATUSES[:failed]
  ] }

  def total_score
    assessments.sum(:score)
  end
end
