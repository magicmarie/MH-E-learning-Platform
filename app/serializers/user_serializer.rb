class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :role, :active, :organization_name

  def organization_name
    object.organization&.name
  end

  def role
    Constants::Roles::ROLE_NAMES[object.role]
  end
end
