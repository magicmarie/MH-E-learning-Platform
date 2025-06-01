# frozen_string_literal: true

class AssignmentPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    global_admin_or_teacher_or_org_admin? || student_owns_enrollment?
  end

  def create?
    global_admin_or_teacher_or_org_admin?
  end

  def update?
    global_admin_or_teacher_or_org_admin?
  end

  def destroy?
    global_admin_or_teacher_or_org_admin?
  end

  private

  def global_admin_or_teacher_or_org_admin?
    user.global_admin? || user.org_admin? || (user.teacher? && record.enrollment.course.user_id == user.id)
  end


  class Scope < Scope
    def resolve
      if user.global_admin? || user.org_admin?
        scope.all
      elsif user.teacher?
        scope.joins(enrollment: :course).where(courses: { user_id: user.id })
      elsif user.student?
        scope.joins(course: :enrollments).where(enrollments: { user_id: user.id })
      else
        scope.none
      end
    end
  end
end
