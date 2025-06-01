class CreateAssessments < ActiveRecord::Migration[8.0]
  def change
    create_table :assessments do |t|
      t.references :enrollment, null: false, foreign_key: true
      t.references :assignment, null: false, foreign_key: true
      t.float :score
      t.datetime :submitted_at
      t.datetime :assessed_on

      t.timestamps
    end
  end
end
