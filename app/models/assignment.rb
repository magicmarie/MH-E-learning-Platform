# Represents an assignment within a course
#
# Assignments can be quizzes, homework, exams, or projects.
# Each assignment automatically creates assessments for all enrolled students.
class Assignment < ApplicationRecord
  include Constants::AssignmentTypes

  belongs_to :course
  has_many_attached :files, dependent: :destroy
  has_many :assessments, dependent: :destroy, counter_cache: true

  validates :title, :deadline, presence: true
  validates :max_score, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :assignment_type, presence: true, inclusion: { in: ASSIGNMENT_TYPES.values }

  after_create :create_assessments_for_enrollments

  # Returns human-readable assignment type name
  #
  # @return [Symbol] The type name (:quiz, :homework, :exam, :project)
  def assignment_type_name
    Constants::AssignmentTypes::ASSIGNMENT_TYPE_NAMES[assignment_type]
  end

  # Returns assessment count using counter cache
  def assessment_count
    assessments_count
  end

  # Returns submission count using counter cache
  def submissions_count
    self[:submissions_count]
  end

  # Returns assessed count using counter cache
  def assessed_count
    self[:assessed_count]
  end

  # Automatically creates assessments for all enrolled students
  # Uses insert_all for performance with large enrollment counts
  def create_assessments_for_enrollments
    enrollment_ids = course.enrollments.pluck(:id)
    timestamp = Time.current
    
    assessment_records = enrollment_ids.map do |enrollment_id|
      {
        enrollment_id: enrollment_id,
        assignment_id: id,
        score: 0,
        created_at: timestamp,
        updated_at: timestamp
      }
    end

    Assessment.insert_all(assessment_records) if assessment_records.any?
    
    # Update counter cache manually since insert_all bypasses callbacks
    update_column(:assessments_count, assessments.count)
  end
end
