class AddActiveToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :active, :boolean, default: true, null: false
    add_index :users, :active
    add_index :users, :email, unique: true
    add_index :users, [ :organization_id, :active ]
  end
end
