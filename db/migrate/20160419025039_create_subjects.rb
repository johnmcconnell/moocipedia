class CreateSubjects < ActiveRecord::Migration
  def change
    create_table :subjects do |t|
      t.string :value, limit: 200

      t.timestamps
    end
    add_index :subjects, :value, unique: true
  end
end
