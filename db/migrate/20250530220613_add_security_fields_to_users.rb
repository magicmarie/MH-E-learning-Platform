class AddSecurityFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :security_question, :string
    add_column :users, :security_answer_digest, :string
  end
end
