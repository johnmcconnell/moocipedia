class FillInTheBlankQuestionsController < ApplicationController
  before_action :set_lesson, only: [:new, :create]
  before_action :set_question, only: [
    :submit_answer, :edit, :update, :find_aliases, :build_answers,
    :skills
  ]
  before_action :set_answer_submission, only: [:submit_answer]
  helper :question
  respond_to :html

  def skills
  end

  def new
    @question = FillInTheBlankQuestion.default(lesson: @lesson)
  end

  def edit
  end

  def create
    @page = Page.create(
      lesson: @lesson,
      content: FillInTheBlankQuestion.new(
        question_params,
      ),
    )
    respond_with @page
  end

  def build_answers
    answers = answers_from_aliases
    @question.answers += answers
    @page = @question.page
    render 'pages/edit'
  end

  def find_aliases
    @aliases = Alias.query(params[:q])
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

  def submitted_from_recommendations?
    q = params["multiple_choice_question"]
    if q.nil?
      return false
    end
    r = q["on_recommendations"]
    !r.nil?
  end

  def answers_from_aliases
    a_ps = aliases_params
    allowed = {}
    a_ps.each do |a|
      valid_keys = a.keys.delete_if do |key|
        key != '0' && key.to_i == 0
      end
      valid_keys.each do |key|
        allowed[key] = true
      end
    end

    idx = 0
    answers = a_ps.keep_if do |a|
      r = allowed[String(idx)]
      idx += 1
      r
    end

    answers.map! do |a|
      FillInTheBlankAnswer.new(text: a['text'])
    end
  end

  def aliases_params
    params.require(
      :aliases
    )
  end

  def correct_response
    flash[:success] = 'Great Job!'
    if submitted_from_recommendations?
      redirect_to recommendations_users_path
    else
      redirect_to @question.page.decorate.next_link[:path]
    end
  end

  def incorrect_response
    flash[:danger] =
      "Incorrect response '#{@answer_submission}'"
    if submitted_from_recommendations?
      redirect_to recommendations_users_path
    else
      redirect_to @question.page
    end
  end

  def set_question
    id = params[:id]
    @question = FillInTheBlankQuestion.find(id)
  end

  def set_lesson
    id = params[:lesson_id] ||
         params.require(:fill_in_the_blank_question)[:lesson_id]
    @lesson = Lesson.find(id)
  end

  def set_answer_submission
    @answer_submission = params[:answer]
  end

  def question_params
    params.require(:fill_in_the_blank_question)
      .permit(
        answers_attributes: [:id, :text, :_destroy],
        page_content_attributes: [:content],
      )
  end
end
