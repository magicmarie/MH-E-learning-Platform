class CreateEnrollments < ActiveRecord::Migration[8.0]
  def change
    create_table :enrollments do |t|
      t.references :user, null: false, foreign_key: true
      t.references :course, null: false, foreign_key: true
      t.integer :status
      t.string :grade, default: nil, null: true

      t.timestamps

      add_index :enrollments, [ :user_id, :course_id ], unique: true
    end
  end
end
