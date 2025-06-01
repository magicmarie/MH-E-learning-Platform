class Enrollment < ApplicationRecord
  belongs_to :user
  belongs_to :course
  has_many :assessments, dependent: :destroy

  DROPPED = 0
  ACTIVE = 1
  PASSED = 2
  FAILED = 3

  validates :status, presence: true, inclusion: { in: [ DROPPED, ACTIVE, PASSED, FAILED ] }

  def total_score
    assessments.sum(:score)
  end
end
