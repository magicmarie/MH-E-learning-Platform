class CreateCourses < ActiveRecord::Migration[8.0]
  def change
    create_table :courses do |t|
      t.string :name
      t.string :course_code
      t.integer :semester
      t.integer :month
      t.integer :year
      t.boolean :is_completed, default: false, null: false
      t.references :user, null: false, foreign_key: true
      t.references :organization, null: false, foreign_key: true

      t.timestamps
    end

    add_index :courses, [ :course_code, :year, :month, :organization_id ],
         unique: true,
         name: 'index_unique_course_details'
  end
end
