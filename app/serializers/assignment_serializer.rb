class AssignmentSerializer < ActiveModel::Serializer
  attributes :id, :title, :assignment_type_name, :max_score, :deadline,
             :assessments_count, :submissions_count, :assessed_count,
             :files

  def files
    object.files.map do |file|
      {
        filename: file.filename.to_s,
        content_type: file.content_type,
        byte_size: file.byte_size,
        url: rails_blob_url(file, host: "http://localhost:3000")
      }
    end
  end
end
