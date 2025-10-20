# frozen_string_literal: true

module UserManagement
  extend ActiveSupport::Concern
  include Pundit::Authorization

  included do
    before_action :set_user, only: %i[activate deactivate update destroy]
    after_action :log_user_action, only: %i[activate deactivate update destroy]
  end

  def index
    authorize User
    users = policy_scope(User).where(active: true)
    users = users.where.not(role: Constants::Roles::ROLES[:global_admin]) unless current_user.global_admin?
    render json: users
  end

  def activate
    authorize @user, :activate?

    if @user.active?
      render_message "User is already active"
    else
      @user.update(active: true, activated_by_id: current_user.id)
      render_message "User activated"
    end
  end

  def deactivate
    authorize @user, :deactivate?
    @user.update(active: false, deactivated_at: Time.current, deactivated_by_id: current_user.id)
    render_message "User deactivated"
  end

  def update
    authorize @user

    if @user.update(user_params)
      render json: @user, status: :ok
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @user
    @user.destroy
    head :no_content
  end

  private

  def set_user
    @user = user_scope.find_by(id: params[:id])
    render_not_found unless @user
  end

  def user_params
    params.permit(:email)
  end

  def user_scope
    raise NotImplementedError, "#{self.class.name} must define #user_scope"
  end

  def render_message(message, status: :ok)
    render json: { message: message }, status: status
  end

  def render_not_found
    render json: { error: "User not found" }, status: :not_found
  end

  def log_user_action
    return unless @user.present?

    Rails.logger.info(
      "[UserManagement] #{current_user.email} performed #{action_name.upcase} on user ##{@user.id} (#{@user.email})"
    )
  end
end
