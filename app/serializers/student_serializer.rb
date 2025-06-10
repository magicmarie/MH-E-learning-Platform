class StudentSerializer < ActiveModel::Serializer
  attributes :id, :email

  has_many :enrollments
end
