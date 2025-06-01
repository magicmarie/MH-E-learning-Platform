class CreateAssignments < ActiveRecord::Migration[8.0]
  def change
    create_table :assignments do |t|
      t.string :title
      t.string :assignment_type
      t.integer :max_score
      t.datetime :deadline
      t.references :course, null: false, foreign_key: true

      t.timestamps
    end
  end
end
