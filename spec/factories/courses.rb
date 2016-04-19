# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :course do
    sequence :id
    title "Test Title"
    description "Test Description"

    association :subject, factory: :subject
    association :topic, factory: :topic

    factory :course_with_lessons do
      lessons { create_list(:lesson, 3) }
    end

    factory :example_course do
      lessons { create_list(:example_lesson, 3) }
    end

    factory :new_course do
      title "New Title"
      description "New Description"

      association :subject, factory: :new_subject
      association :topic, factory: :new_topic
    end
  end
end
