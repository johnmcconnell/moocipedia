class CreateRatings < ActiveRecord::Migration
  def change
    create_table :ratings do |t|
      t.references :rateable, index: true, polymorphic: true
      t.references :topic, index: true
      t.integer    :score

      t.timestamps
    end

    add_index(
      :ratings,
      [
        :rateable_type,
        :rateable_id,
        :topic_id,
        :score,
      ],
      name: :quick_query_index,
    )
  end
end
