# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :subject do
    value "Test Subject"

    factory :new_subject do
      value "New Subject"
    end

    initialize_with do
      Subject.find_or_initialize_by(value: value)
    end
  end
end
