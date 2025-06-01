class EnrollmentSerializer < ActiveModel::Serializer
  attributes :id, :status
  belongs_to :user
  belongs_to :course
end
