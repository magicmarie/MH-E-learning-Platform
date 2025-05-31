# frozen_string_literal: true

module Authenticatable
  extend ActiveSupport::Concern

  included do
    before_action :authorize_request
    attr_reader :current_user
  end

  private

  def authorize_request
    header = request.headers["Authorization"]
    token = header.split(" ").last if header

    decoded = JsonWebToken.decode(token)
    if decoded.nil?
      render json: { error: "Token expired or invalid" }, status: :unauthorized
      return
    end

    @current_user = User.find_by(id: decoded[:user_id])

    if @current_user.nil? || !@current_user.active?
      render json: { error: "Unauthorized or Account deactivated" }, status: :unauthorized
    end
  end
end
