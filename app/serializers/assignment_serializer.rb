class AssignmentSerializer < ActiveModel::Serializer
  attributes :id, :title, :assignment_type, :max_score, :deadline

  def assignment_type
    Constants::AssignmentTypes::ASSIGNMENT_TYPE_NAMES[object.assignment_type]
  end
end
