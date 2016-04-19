class CreateTopics < ActiveRecord::Migration
  def change
    create_table :topics do |t|
      t.string :value, limit: 200

      t.timestamps
    end
    add_index :topics, :value, unique: true
  end
end
