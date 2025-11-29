# frozen_string_literal: true

# Configuration for authentication and authorization
module AuthConfig
  # JWT token expiration times
  TOKEN_EXPIRY = ENV.fetch("AUTH_TOKEN_EXPIRY", 5.hours.to_i).to_i.seconds
  RESET_TOKEN_EXPIRY = ENV.fetch("RESET_TOKEN_EXPIRY", 1.hour.to_i).to_i.seconds
  WELCOME_TOKEN_EXPIRY = ENV.fetch("WELCOME_TOKEN_EXPIRY", 15.minutes.to_i).to_i.seconds

  # Password requirements
  MIN_PASSWORD_LENGTH = ENV.fetch("MIN_PASSWORD_LENGTH", 8).to_i
  TEMP_PASSWORD_LENGTH = ENV.fetch("TEMP_PASSWORD_LENGTH", 12).to_i
end
