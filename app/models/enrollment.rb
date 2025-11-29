# Represents a student's enrollment in a course
#
# Tracks enrollment status and grade. Each enrollment can have
# multiple assessments corresponding to course assignments.
class Enrollment < ApplicationRecord
  include Constants::EnrollmentStatus

  belongs_to :user
  belongs_to :course, counter_cache: true
  has_many :assessments, dependent: :destroy

  after_initialize :set_defaults, if: :new_record?

  validates :status, inclusion: { in: STATUSES.values }, allow_nil: true

  # Returns human-readable status name
  #
  # @return [Symbol] The status name
  def status_name
    STATUS_NAMES[status]
  end

  private

  def set_defaults
    self.status ||= STATUSES[:active]
    self.grade ||= nil
  end
end
