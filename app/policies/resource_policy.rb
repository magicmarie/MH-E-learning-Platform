# frozen_string_literal: true

class ResourcePolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def create?
    user.global_admin? || org_scoped_creator?
  end

  def update?
    user.global_admin? || org_scoped_creator?
  end

  def destroy?
    user.global_admin? || org_scoped_creator?
  end

  class Scope < ResourcePolicy::Scope
    def resolve
      if user.global_admin?
        scope.all
      else
        scope.joins(:course).where(courses: { organization_id: user.organization_id })
      end
    end
  end

  private

  def org_scoped_creator?
    (user.org_admin? || user.teacher?) &&
      record.course.organization_id == user.organization_id
  end
end
