# frozen_string_literal: true

module Errors
  # Base authentication error
  class AuthenticationError < StandardError
    attr_reader :status

    def initialize(message = "Authentication failed", status: :unauthorized)
      super(message)
      @status = status
    end
  end
end
