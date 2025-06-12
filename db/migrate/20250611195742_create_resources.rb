class CreateResources < ActiveRecord::Migration[8.0]
  def change
    create_table :resources do |t|
      t.string :title
      t.text :description
      t.boolean :visible, default: false
      t.references :course, null: false, foreign_key: true

      t.timestamps
    end
  end
end
