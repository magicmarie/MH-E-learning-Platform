class UserSerializer < ActiveModel::Serializer
  attributes :email, :role, :active, :organization_name

  def organization_name
    object.organization&.name
  end
end
