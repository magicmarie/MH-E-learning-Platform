class OrganizationPolicy < ApplicationPolicy
  def index?
    user.global_admin?
  end

  def create?
    user.global_admin?
  end

  def destroy?
    user.global_admin?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.global_admin?
        scope.all
      else
        scope.none
      end
    end
  end
end
