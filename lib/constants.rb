# frozen_string_literal: true

# Application-wide constants for roles, semesters, assignment types, and enrollment statuses
#
# These modules can be included in models to access constants without deep nesting.
# @example
#   class User < ApplicationRecord
#     include Constants::Roles
#     # Now can use ROLES[:global_admin] instead of Constants::Roles::ROLES[:global_admin]
#   end
module Constants
  # User role constants
  module Roles
    ROLES = {
      global_admin: 0,
      org_admin: 1,
      teacher: 2,
      student: 3
    }.freeze

    ROLE_NAMES = ROLES.invert.freeze

    # Returns human-readable role name
    #
    # @param role_value [Integer] The role integer value
    # @return [Symbol, nil] The role name or nil if not found
    def self.role_name(role_value)
      ROLE_NAMES[role_value]
    end

    # Checks if a role value is valid
    #
    # @param role_value [Integer] The role integer value
    # @return [Boolean] True if valid
    def self.valid_role?(role_value)
      ROLE_NAMES.key?(role_value)
    end
  end


  # Course semester constants
  module Semesters
    SEMESTERS = {
      first: 1,
      second: 2
    }.freeze

    SEMESTER_NAMES = SEMESTERS.invert.freeze

    # Returns human-readable semester name
    #
    # @param semester_value [Integer] The semester integer value
    # @return [Symbol, nil] The semester name or nil if not found
    def self.semester_name(semester_value)
      SEMESTER_NAMES[semester_value]
    end

    # Checks if a semester value is valid
    #
    # @param semester_value [Integer] The semester integer value
    # @return [Boolean] True if valid
    def self.valid_semester?(semester_value)
      SEMESTER_NAMES.key?(semester_value)
    end
  end

  # Assignment type constants
  module AssignmentTypes
    ASSIGNMENT_TYPES = {
      quiz: 0,
      homework: 1,
      exam: 2,
      project: 3
    }.freeze

    ASSIGNMENT_TYPE_NAMES = ASSIGNMENT_TYPES.invert.freeze

    # Returns human-readable assignment type name
    #
    # @param type_value [Integer] The assignment type integer value
    # @return [Symbol, nil] The type name or nil if not found
    def self.type_name(type_value)
      ASSIGNMENT_TYPE_NAMES[type_value]
    end

    # Checks if an assignment type value is valid
    #
    # @param type_value [Integer] The assignment type integer value
    # @return [Boolean] True if valid
    def self.valid_type?(type_value)
      ASSIGNMENT_TYPE_NAMES.key?(type_value)
    end
  end

  # Enrollment status constants
  module EnrollmentStatus
    STATUSES = {
      dropped: 0,
      active: 1,
      passed: 2,
      failed: 3
    }.freeze

    STATUS_NAMES = STATUSES.invert.freeze

    # Returns human-readable status name
    #
    # @param status_value [Integer] The status integer value
    # @return [Symbol, nil] The status name or nil if not found
    def self.status_name(status_value)
      STATUS_NAMES[status_value]
    end

    # Checks if a status value is valid
    #
    # @param status_value [Integer] The status integer value
    # @return [Boolean] True if valid
    def self.valid_status?(status_value)
      STATUS_NAMES.key?(status_value)
    end
  end
end
