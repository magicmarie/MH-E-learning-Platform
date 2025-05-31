class ApplicationController < ActionController::API
  include Pundit

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def user_not_authorized
    render json: { error: "Access denied" }, status: :forbidden
  end
end
