class MultipleChoiceQuestionsController < ApplicationController
  before_action :set_lesson, only: [:new, :create]
  before_action :set_question, only: [:skills, :submit_answer, :edit, :update]
  before_action :set_answer_submission, only: [:submit_answer]
  helper :question
  respond_to :html

  def skills
  end

  def new
    @question = MultipleChoiceQuestion.default(lesson: @lesson)
  end

  def edit
  end

  def create
    @page = Page.create(
      lesson: @lesson,
      content: MultipleChoiceQuestion.new(
        question_params,
      ),
    )
    respond_with @page
  end

  def update
    @question.update(question_params)
    respond_with @question.page
  end

  def submit_answer
    if @question.correct_answer?(@answer_submission)
      if current_user.nil?
        flash[:warning] = "You are not logged in. Your progress is not being recorded."
      else
        Rating.update_elo(
          current_user,
          @question,
          true,
        )
      end
      correct_response
    else
      if current_user.nil?
        flash[:warning] = "You are not logged in. Your progress is not being recorded."
      else
        Rating.update_elo(
          current_user,
          @question,
          false,
        )
      end
      incorrect_response
    end
  end

  private

  def correct_response
    flash[:success] = 'Great Job!'
    redirect_to @question.page.decorate.next_link[:path]
  end

  def incorrect_response
    flash[:danger] =
      "Incorrect response '#{@answer_submission}'"
    redirect_to @question.page
  end

  def set_question
    id = params[:id]
    @question = MultipleChoiceQuestion.find(id)
  end

  def set_lesson
    id = params[:lesson_id] ||
         params.require(:multiple_choice_question)[:lesson_id]
    @lesson = Lesson.find(id)
  end

  def set_answer_submission
    @answer_submission = params[:answer]
  end

  def question_params
    params.require(:multiple_choice_question)
      .permit(
        answers_attributes: [:id, :text, :correct, :_destroy],
        page_content_attributes: [:content],
      )
  end
end
