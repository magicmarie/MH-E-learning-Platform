class ApplicationController < ActionController::API
  include Pundit

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  rescue_from Pundit::NotDefinedError do
    render json: { error: "Authorization policy not found" }, status: :internal_server_error
  end

  private

  def user_not_authorized
    render json: { error: "Access denied" }, status: :forbidden
  end
end
