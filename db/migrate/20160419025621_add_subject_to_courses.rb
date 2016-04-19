class AddSubjectToCourses < ActiveRecord::Migration
  def change
    change_table :courses do |t|
      t.rename :subject, :subject_raw
    end

    add_reference :courses, :subject, index: true
  end
end
