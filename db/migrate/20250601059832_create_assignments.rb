class CreateAssignments < ActiveRecord::Migration[8.0]
  def change
    create_table :assignments do |t|
      t.string :title
      t.integer :assignment_type
      t.integer :max_score
      t.datetime :deadline
      t.references :course, null: false, foreign_key: true

      t.timestamps
    end

    add_index :assignments, [ :title, :course_id ], unique: true, name: 'index_unique_assignment_per_course'
  end
end
