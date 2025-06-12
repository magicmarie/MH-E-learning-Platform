class ResourceSerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers

  attributes :id, :title, :description, :course_name, :files

  def course_name
    object.course&.name
  end

  def files
    object.files.map do |file|
      {
        filename: file.filename.to_s,
        content_type: file.content_type,
        byte_size: file.byte_size,
        url: rails_blob_url(file, only_path: true)
      }
    end
  end
end
