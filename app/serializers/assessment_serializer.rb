class AssessmentSerializer < ActiveModel::Serializer
  attributes :id, :updated_at, :assessed_on, :score
end
