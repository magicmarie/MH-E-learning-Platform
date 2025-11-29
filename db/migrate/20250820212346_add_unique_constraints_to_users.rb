class AddUniqueConstraintsToUsers < ActiveRecord::Migration[8.0]
  def change
    # Unique constraint for users within organizations (email + org_id must be unique)
    add_index :users, [ :email, :organization_id ],
              unique: true,
              name: 'index_users_on_email_and_org_id',
              where: "organization_id IS NOT NULL"

    # Unique constraint for global admin (email must be unique when org_id is NULL)
    add_index :users, [ :email ],
              unique: true,
              name: 'index_users_on_email_global_admin',
              where: "organization_id IS NULL"
  end
end
