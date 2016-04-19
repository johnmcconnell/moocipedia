class MultipleChoiceQuestion < ActiveRecord::Base
  include Rateable

  belongs_to :page_content
  has_one :lesson, through: :page
  has_one :course, through: :lesson
  has_many :answers, class_name: 'MultipleChoiceAnswer'

  accepts_nested_attributes_for :answers, allow_destroy: true
  accepts_nested_attributes_for :page_content

  has_one :page, as: :content
  has_many :ratings, as: :rateable

  def self.default(attributes = {})
    new({
      page_content: PageContent.new,
      answers: [correct_answer, incorrect_answer],
    }.merge(attributes))
  end

  def self.correct_answer
    MultipleChoiceAnswer.new(correct: true)
  end

  def self.incorrect_answer
    MultipleChoiceAnswer.new(correct: false)
  end

  def correct_answer?(text)
    answers.any? do |answer|
      answer.correct && answer.text == text
    end
  end

  def to_s
    page_content.to_s
  end

  def ratings
    orig = super
    if orig.empty?
      orig << Rating.new(
        topic: course.topic.value,
        score: 3000,
      )
    end
    orig
  end
end
