# frozen_string_literal: true

class OrganizationSerializer < ActiveModel::Serializer
  attributes :id, :name, :organization_code, :settings
end
