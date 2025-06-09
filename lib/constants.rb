# frozen_string_literal: true

module Constants
  module Roles
    ROLES = {
      global_admin: 0,
      org_admin: 1,
      teacher: 2,
      student: 3
    }.freeze

    ROLE_NAMES = ROLES.invert.freeze
  end


  module Semesters
    SEMESTERS = {
      first: 1,
      second: 2
    }.freeze

    SEMESTER_NAMES = SEMESTERS.invert.freeze
  end

  module AssignmentTypes
    ASSIGNMENT_TYPES = {
      quiz: 0,
      homework: 1,
      exam: 2,
      project: 3
    }.freeze

    ASSIGNMENT_TYPE_NAMES = ASSIGNMENT_TYPES.invert.freeze
  end

  module EnrollmentStatus
    STATUSES = {
      dropped: 0,
      active: 1,
      passed: 2,
      failed: 3
    }.freeze

    STATUS_NAMES = STATUSES.invert.freeze
  end
end
