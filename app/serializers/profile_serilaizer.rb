class ProfileSerializer < ActiveModel::Serializer
  attributes :id, :email, :role, :organization_name

  def organization_name
    object.organization&.name
  end
end
