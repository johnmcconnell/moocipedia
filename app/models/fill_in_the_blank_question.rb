class FillInTheBlankQuestion < ActiveRecord::Base
  include Rateable

  belongs_to :page_content
  has_one :lesson, through: :page
  has_one :course, through: :lesson
  has_many :answers, class_name: 'FillInTheBlankAnswer', dependent: :destroy

  accepts_nested_attributes_for :answers, allow_destroy: true
  accepts_nested_attributes_for :page_content

  has_one :page, as: :content
  has_many :ratings, as: :rateable

  def self.default(attributes = {})
    new({
      answers: [FillInTheBlankAnswer.new],
      page_content: PageContent.new,
    }.merge(attributes))
  end

  def correct_answer?(text)
    answers.any? do |answer|
      answer.correct? text
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
