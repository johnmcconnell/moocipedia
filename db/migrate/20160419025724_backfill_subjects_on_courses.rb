class BackfillSubjectsOnCourses < ActiveRecord::Migration
  def change
    Course.find_each do |c|
      s = Subject.find_or_initialize_by(value: c.subject_raw)

      if s.new_record?
        s.save!
      end

      c.update!(subject_id: s.id)
    end

    remove_column :courses, :subject_raw
  end
end
