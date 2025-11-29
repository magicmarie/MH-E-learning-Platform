# frozen_string_literal: true

# Provides centralized error handling for API controllers
#
# This concern rescues common exceptions and formats error responses
# consistently across all controllers.
module ErrorHandler
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found
    rescue_from ActiveRecord::RecordInvalid, with: :handle_validation_error
    rescue_from ::Errors::AuthenticationError, with: :handle_authentication_error
    rescue_from ::Errors::AuthorizationError, with: :handle_authorization_error
    rescue_from ::Errors::ValidationError, with: :handle_validation_error
    rescue_from Pundit::NotAuthorizedError, with: :handle_pundit_unauthorized
    rescue_from Pundit::NotDefinedError, with: :handle_pundit_not_defined
  end

  private

  # Renders a standardized error response
  #
  # @param message [String] Error message
  # @param status [Symbol] HTTP status code
  # @param errors [Array<String>] Additional error details
  def render_error(message:, status: :bad_request, errors: [])
    response_body = { error: message }
    response_body[:errors] = errors if errors.any?

    render json: response_body, status: status
  end

  def handle_not_found(exception)
    render_error(
      message: "Resource not found",
      status: :not_found,
      errors: [exception.message]
    )
  end

  def handle_validation_error(exception)
    errors = if exception.respond_to?(:record)
               exception.record.errors.full_messages
             elsif exception.respond_to?(:errors)
               exception.errors
             else
               [exception.message]
             end

    render_error(
      message: "Validation failed",
      status: :unprocessable_entity,
      errors: errors
    )
  end

  def handle_authentication_error(exception)
    render_error(
      message: exception.message,
      status: exception.status
    )
  end

  def handle_authorization_error(exception)
    render_error(
      message: exception.message,
      status: exception.status
    )
  end

  def handle_pundit_unauthorized
    render_error(
      message: "Access denied",
      status: :forbidden
    )
  end

  def handle_pundit_not_defined
    Rails.logger.error("Pundit policy not defined")
    render_error(
      message: "Authorization policy not found",
      status: :internal_server_error
    )
  end
end
