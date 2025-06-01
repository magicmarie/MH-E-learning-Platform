class CourseSerializer < ActiveModel::Serializer
  attributes :id, :name, :course_code, :semester, :month, :year, :grade
  has_one :user
  has_one :organization
end
