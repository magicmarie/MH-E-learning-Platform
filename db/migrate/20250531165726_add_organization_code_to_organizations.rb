class AddOrganizationCodeToOrganizations < ActiveRecord::Migration[8.0]
  def change
    add_column :organizations, :organization_code, :string
    add_index :organizations, :organization_code, unique: true
  end
end
