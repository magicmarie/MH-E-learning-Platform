# frozen_string_literal: true

# Handles encoding and decoding of JSON Web Tokens for authentication
#
# @example Encoding a payload
#   token = JsonWebToken.encode({ user_id: 123 }, 1.hour.from_now)
#
# @example Decoding a token
#   payload = JsonWebToken.decode(token)
#   # => { user_id: 123, exp: 1234567890 }
class JsonWebToken
  SECRET_KEY = Rails.application.secret_key_base

  # Encodes a payload into a JWT token
  #
  # @param payload [Hash] The data to encode
  # @param exp [ActiveSupport::TimeWithZone] Token expiration time
  # @return [String] The encoded JWT token
  def self.encode(payload, exp = AuthConfig::TOKEN_EXPIRY.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, SECRET_KEY)
  end

  # Decodes a JWT token and returns the payload
  #
  # @param token [String] The JWT token to decode
  # @return [HashWithIndifferentAccess] The decoded payload
  # @raise [Errors::TokenExpiredError] If the token has expired
  # @raise [Errors::TokenInvalidError] If the token is invalid or malformed
  def self.decode(token)
    decoded = JWT.decode(token, SECRET_KEY)[0]
    HashWithIndifferentAccess.new(decoded)
  rescue JWT::ExpiredSignature => e
    raise ::Errors::TokenExpiredError, e.message
  rescue JWT::DecodeError => e
    raise ::Errors::TokenInvalidError, e.message
  end
end
