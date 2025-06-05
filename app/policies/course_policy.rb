# frozen_string_literal: true

class CoursePolicy < ApplicationPolicy
  def index?
    user.org_admin? || user.teacher?
  end

  def show?
    return true if user.global_admin?
    return true if user.org_admin? && record.organization_id == user.organization_id
    return true if user.teacher? && record.user_id == user.id
    return true if user.student? && record.users.include?(user) # via enrollments
    false
  end

  def create?
    user.org_admin? || user.teacher?
  end

  def update?
    user.org_admin? || (user.teacher? && record.user_id == user.id)
  end

  def destroy?
    user.org_admin? || (user.teacher? && record.user_id == user.id)
  end

  class Scope < Scope
    def resolve
      if user.global_admin?
        scope.all
      elsif user.org_admin?
        scope.where(organization: user.organization)
      elsif user.teacher?
        scope.where(user: user)
      elsif user.student?
        scope.joins(:enrollments).where(enrollments: { user_id: user.id })
      else
        scope.none
      end
    end
  end
end
