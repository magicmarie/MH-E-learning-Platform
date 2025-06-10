class AssignmentSerializer < ActiveModel::Serializer
  attributes :id, :title, :assignment_type_name, :max_score, :deadline,
             :assessment_count, :submissions_count, :assessed_count
end
