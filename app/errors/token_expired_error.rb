# frozen_string_literal: true

module Errors
  # Raised when a JWT token has expired
  class TokenExpiredError < AuthenticationError
    def initialize(message = "Token has expired")
      super(message, status: :unauthorized)
    end
  end
end
