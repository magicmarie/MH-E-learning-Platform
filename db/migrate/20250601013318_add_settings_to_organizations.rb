class AddSettingsToOrganizations < ActiveRecord::Migration[8.0]
  def change
    add_column :organizations, :settings, :jsonb, default: {}, null: false
    add_index :organizations, :settings, using: :gin
  end
end
