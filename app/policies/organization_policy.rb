class OrganizationPolicy < ApplicationPolicy
  def create?
    user.global_admin?
  end

  def destroy?
    user.global_admin?
  end

  def index_stats?
    user.global_admin?
  end

  def show?
    user.global_admin? || (user.org_admin? && user.organization_id == record.id)
  end

  def update?
    show?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.global_admin?
        scope.all
      elsif user.org_admin?
        scope.where(id: user.organization_id)
      else
        scope.none
      end
    end
  end
end
