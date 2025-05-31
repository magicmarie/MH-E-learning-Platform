module UserManagement
  extend ActiveSupport::Concern
  include Pundit

  included do
    before_action :authorize_request
  end

  def index
    authorize User
    users = policy_scope(User).where(active: true)
    users = users.where.not(role: User::GLOBAL_ADMIN) unless current_user.global_admin?
    render json: users
  end

  def activate
    user = find_user_in_scope(params[:id])
    return render_not_found unless user

    authorize user, :activate?

    if user.active?
      render json: { message: "User is already active" }
    else
      user.update(active: true)
      render json: { message: "User activated" }
    end
  end

  def deactivate
    user = find_user_in_scope(params[:id])
    return render_not_found unless user

    authorize user, :deactivate?

    user.update(active: false, deactivated_at: Time.current, deactivated_by_id: current_user.id)
    render json: { message: "User deactivated" }
  end

  private

  def user_params
    params.permit(:email, :password, :password_confirmation, :role)
  end

  def find_user_in_scope(id)
    user_scope.find_by(id: id)
  end

  def render_not_found
    render json: { error: "User not found" }, status: :not_found
  end

  def user_scope
    raise NotImplementedError, "Define user_scope in your controller"
  end
end
