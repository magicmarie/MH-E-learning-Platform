class Assignment < ApplicationRecord
  belongs_to :course
  has_many_attached :files, dependent: :destroy
  has_many :assessments, dependent: :destroy

  validates :title, :deadline, presence: true
  validates :max_score, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :assignment_type, presence: true, inclusion: { in: [
    Constants::AssignmentTypes::ASSIGNMENT_TYPES[:quiz],
    Constants::AssignmentTypes::ASSIGNMENT_TYPES[:homework],
    Constants::AssignmentTypes::ASSIGNMENT_TYPES[:exam],
    Constants::AssignmentTypes::ASSIGNMENT_TYPES[:project]
  ] }

  def assignment_type_name
    Constants::AssignmentTypes::ASSIGNMENT_TYPE_NAMES[self.assignment_type]
  end

  def assessment_count
    assessments.count
  end

  def submissions_count
    assessments.where.not(submitted_at: nil).count
  end

  def assessed_count
    assessments.where.not(assessed_on: nil).count
  end
end
