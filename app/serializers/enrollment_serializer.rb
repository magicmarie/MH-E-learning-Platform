class EnrollmentSerializer < ActiveModel::Serializer
  attributes :id, :status
  belongs_to :user
  belongs_to :course

  def status
    Constants::EnrollmentStatus::STATUS_NAMES[object.status]
  end
end
