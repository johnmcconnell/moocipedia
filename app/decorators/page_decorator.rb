class PageDecorator < PartialDecorator
  delegate_all

  def type
    content.decorate.type
  end

  def number
    position
  end

  def next_link
    if lower_item.nil?
      helpers = Rails.application.routes.url_helpers
      lower_lesson = lesson.lower_item

      if lower_lesson.nil?
        {
          text: 'Finish Course!',
          path:  helpers.finished_course_path(course),
        }
      else
        {
          text: "Continue on to Lesson: #{lower_lesson.name}",
          path: lower_lesson,
        }
      end
    else
      {
        text: content.decorate.next_page_text,
        path: lower_item,
      }
    end
  end
end
