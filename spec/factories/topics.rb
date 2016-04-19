# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :topic do
    value "Test Topic"

    factory :new_topic do
      value "New Topic"
    end

    initialize_with do
      Topic.find_or_initialize_by(value: value)
    end
  end
end
