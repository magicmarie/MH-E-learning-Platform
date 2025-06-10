class EnrollmentSerializer < ActiveModel::Serializer
  attributes :id, :status, :grade, :student_id, :total_score, :course

  def status
    Constants::EnrollmentStatus::STATUS_NAMES[object.status]
  end

  def student_id
    object.user.id
  end

  def total_score
    object.total_score
  end

  def course
    object.course.name
  end
end
