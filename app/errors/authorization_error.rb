# frozen_string_literal: true

module Errors
  # Raised when a user lacks permission to perform an action
  class AuthorizationError < StandardError
    attr_reader :status

    def initialize(message = "Access denied", status: :forbidden)
      super(message)
      @status = status
    end
  end
end
