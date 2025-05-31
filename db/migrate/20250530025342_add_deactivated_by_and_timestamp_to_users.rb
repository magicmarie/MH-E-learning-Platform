class AddDeactivatedByAndTimestampToUsers < ActiveRecord::Migration[6.1]
  def change
    add_reference :users, :deactivated_by, foreign_key: { to_table: :users }
    add_column :users, :deactivated_at, :datetime
  end
end
