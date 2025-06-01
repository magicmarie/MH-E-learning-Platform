class UserPolicy < ApplicationPolicy
  def index?
    user.org_admin? || user.global_admin?
  end

  def create?
    if user.global_admin?
      true
    elsif user.org_admin?
      # org admins can create only teachers and students (no org admins)
      !record.org_admin?
    else
      false
    end
  end

  def activate?
    return false unless user.active?
    user.global_admin? ||
      (user.org_admin? &&
      record.organization_id == user.organization_id &&
      !record.global_admin? && !record.org_admin?)
  end

  def deactivate?
    activate? # same logic as activate
  end

  def update?
    activate?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.global_admin?
        scope.all
      elsif user.org_admin?
        scope.where(organization_id: user.organization_id)
      else
        scope.none
      end
    end
  end
end
