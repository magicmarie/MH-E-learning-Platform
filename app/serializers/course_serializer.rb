class CourseSerializer < ActiveModel::Serializer
  attributes :id, :name, :course_code, :semester, :month, :year,
             :enrollment_count, :assignment_type_counts
end
