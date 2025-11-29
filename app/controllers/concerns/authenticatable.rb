# frozen_string_literal: true

# Provides JWT-based authentication for API controllers
#
# This concern handles:
# - Extracting and validating JWT tokens from Authorization headers
# - Setting the current_user from the decoded token
# - Logging authentication attempts
#
# @example
#   class UsersController < ApplicationController
#     include Authenticatable
#   end
module Authenticatable
  extend ActiveSupport::Concern

  included do
    before_action :authorize_request
    after_action :log_auth_attempt
    attr_reader :current_user
  end

  private

  # Validates JWT token and sets current_user
  #
  # @raise [Errors::TokenExpiredError] If token has expired
  # @raise [Errors::TokenInvalidError] If token is invalid
  # @raise [Errors::AuthenticationError] If user not found or inactive
  def authorize_request
    token = extract_token_from_header
    raise Errors::AuthenticationError, "Missing authentication token" unless token

    decoded = JsonWebToken.decode(token)
    @current_user = User.find_by(id: decoded[:user_id])

    unless @current_user&.active?
      raise Errors::AuthenticationError, "Unauthorized or account deactivated"
    end
  end

  # Extracts JWT token from Authorization header
  #
  # @return [String, nil] The extracted token or nil
  def extract_token_from_header
    header = request.headers["Authorization"]
    return nil unless header&.start_with?("Bearer ")

    header.split(" ").last
  end

  # Logs authentication attempts for audit trail
  def log_auth_attempt
    Rails.logger.info(
      "[Auth] #{current_user&.email || 'Guest'} accessed #{controller_name}##{action_name}"
    )
  end
end
