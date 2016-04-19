class BackfillTopicsOnCourses < ActiveRecord::Migration
  def change
    Course.find_each do |c|
      t = Topic.find_or_initialize_by(value: c.topic_raw)

      if t.new_record?
        t.save!
      end

      c.update!(topic_id: t.id)
    end

    remove_column :courses, :topic_raw
  end
end
