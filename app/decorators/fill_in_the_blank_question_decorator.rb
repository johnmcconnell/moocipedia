class FillInTheBlankQuestionDecorator < QuestionDecorator
  delegate_all

  def self.type
    @type ||= 'Fill in the blank question'.freeze
  end

  def type
    self.class.type
  end
  
  def next_page_text
    'Skip quiz'.freeze
  end

  def create_for_section_url
    h.create_for_section_fill_in_the_blank_questions_path
  end
end
