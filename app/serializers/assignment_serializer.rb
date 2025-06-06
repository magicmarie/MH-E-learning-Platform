class AssignmentSerializer < ActiveModel::Serializer
  attributes :id, :title, :assignment_type, :max_score, :deadline
end
