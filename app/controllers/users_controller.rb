class UsersController < ApplicationController
  def details
  end

  def extra_params
    @extra_params ||= []
  end

  def recommendations
    expected_p = 0.8
    within = 2000
    limit = 10

    sql_array = [
      Rating::REC_SQL,
      current_user.id,
      current_user.class.name,
      within,
      within,
      limit,
    ]

    sql = ActiveRecord::Base.send(
      :sanitize_sql_array,
      sql_array,
    )

    @recommendations = ActiveRecord::Base
      .connection
      .select_all(
        sql,
      )

    @questions = @recommendations.map do |r|
      rateable_type = r['rateable_type']
      rateable_id = Integer(r['rateable_id'])

      question = nil
      if rateable_type == 'MultipleChoiceQuestion'
        question = MultipleChoiceQuestion.where(
          id: rateable_id,
        ).first
      elsif rateable_type == 'FillInTheBlankQuestion'
        question = FillInTheBlankQuestion.where(
          id: rateable_id,
        ).first
      else
        fail "found: #{r} needs key: :rateable_type"
      end

      if question.nil?
        binding.pry
        fail "found: #{r} needs matching question"
      end

      question
    end

    @questions.sort_by! do |q|
      p = Rating.p_user_wins(
        current_user,
        q.ratings,
      )

      p = p.fetch(:prob)

      (expected_p - p).abs
    end
  end
end

