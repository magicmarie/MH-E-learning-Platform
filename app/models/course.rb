# Represents a course in the learning management system
#
# A course belongs to a teacher and organization, and can have multiple
# enrollments, assignments, and resources. Courses are uniquely identified
# by name, code, semester, month, year, and organization.
class Course < ApplicationRecord
  include Constants::Semesters
  include Constants::AssignmentTypes

  belongs_to :user
  belongs_to :organization

  has_many :enrollments, counter_cache: true
  has_many :users, through: :enrollments
  has_many :assignments, dependent: :destroy, counter_cache: true
  has_many :resources, dependent: :destroy

  validates :name, :course_code, :semester, :month, :year, presence: true

  validates :month, inclusion: { in: 1..12, message: "must be between 1 and 12" }
  validates :year, numericality: { only_integer: true, greater_than_or_equal_to: 1900, message: "must be a valid year" }
  validates :semester, inclusion: { in: SEMESTERS.values }

  validates :month, uniqueness: {
    scope: [ :name, :course_code, :semester, :year, :organization_id ],
    message: "must be unique for the same course details in a given year and semester"
  }

  # Returns the enrollment count using counter cache
  def enrollment_count
    enrollments_count
  end

  # Returns counts of assignments grouped by type
  #
  # @return [Hash] Assignment type names as keys, counts as values
  def assignment_type_counts
    zero_counts = ASSIGNMENT_TYPE_NAMES.values.map { |type| [type.to_s, 0] }.to_h
    raw_counts = assignments.group(:assignment_type).count
      .transform_keys { |int_key| ASSIGNMENT_TYPE_NAMES[int_key].to_s }
    zero_counts.merge(raw_counts)
  end

  # Returns the semester name
  #
  # @return [Symbol] :first or :second
  def semester_name
    SEMESTER_NAMES[semester]
  end

  # Alias for backwards compatibility with tests
  alias_method :semester_info, :semester_name
end
