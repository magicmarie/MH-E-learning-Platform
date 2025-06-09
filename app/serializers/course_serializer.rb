class CourseSerializer < ActiveModel::Serializer
  attributes :id, :name, :course_code, :semester, :month, :year, :is_completed
  has_one :user

  def semester
    Constants::Semesters::SEMESTER_NAMES[object.semester]
  end
end
