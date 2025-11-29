# frozen_string_literal: true

module Errors
  # Raised when validation fails
  class ValidationError < StandardError
    attr_reader :status, :errors

    def initialize(message = "Validation failed", errors: [], status: :unprocessable_entity)
      super(message)
      @status = status
      @errors = errors
    end
  end
end
