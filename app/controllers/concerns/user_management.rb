module UserManagement
  extend ActiveSupport::Concern
  include Pundit::Authorization
  included do
    before_action :authorize_request
  end

  def index
    authorize User
    users = policy_scope(User).where(active: true)
    users = users.where.not(role: Constants::Roles::ROLES[:global_admin]) unless current_user.global_admin?
    render json: users
  end

  def activate
    user = find_user_in_scope(params[:id])
    return render_not_found unless user

    authorize user, :activate?

    if user.active?
      render json: { message: "User is already active" }
    else
      user.update(active: true, activated_by_id: current_user.id)
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

  def update
    user = User.find_by(id: params[:id])
    return render json: { error: "User not found" }, status: :not_found unless user

    authorize user

    if user.update(user_params)
      render json: user, status: :ok
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    user = find_user_in_scope(params[:id])
    return render_not_found unless user

    authorize user
    user.destroy
    head :no_content
  end

  private

  def user_params
    params.permit(:email, :role, :organization_id)
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
