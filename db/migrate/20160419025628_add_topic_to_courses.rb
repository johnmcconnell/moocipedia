class AddTopicToCourses < ActiveRecord::Migration
  def change
    change_table :courses do |t|
      t.rename :topic, :topic_raw
    end

    add_reference :courses, :topic, index: true
  end
end
