# frozen_string_literal: true

class EnrollmentPolicy < ApplicationPolicy
  def index?
    user.global_admin? || user.org_admin? || teacher_owns_course?
  end

  def show?
    user.global_admin? || user.org_admin? || teacher_owns_course? || student_self?
  end

  def create?
    user.global_admin? || user.org_admin? || teacher_owns_course?
  end

  def update?
    user.global_admin? || user.org_admin? || teacher_owns_course?
  end

  def destroy?
    user.global_admin? || user.org_admin? || teacher_owns_course?
  end

  private

  def teacher_owns_course?
    user.teacher? && record.course.user_id == user.id
  end

  def student_self?
    user.student? && record.user_id == user.id
  end

  class Scope < Scope
    def resolve
      if user.global_admin?
        scope.all
      elsif user.org_admin?
        scope.joins(:course).where(courses: { organization_id: user.organization_id })
      elsif user.teacher?
        scope.joins(:course).where(courses: { user_id: user.id })
      elsif user.student?
        scope.where(user_id: user.id)
      else
        scope.none
      end
    end
  end
end
