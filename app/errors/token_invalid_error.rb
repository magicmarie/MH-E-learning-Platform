# frozen_string_literal: true

module Errors
  # Raised when a JWT token is invalid or malformed
  class TokenInvalidError < AuthenticationError
    def initialize(message = "Token is invalid")
      super(message, status: :unauthorized)
    end
  end
end
