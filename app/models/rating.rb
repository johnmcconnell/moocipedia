class Rating < ActiveRecord::Base
  belongs_to :rateable, polymorphic: true
  belongs_to :topic
  REC_SQL = %q{
    SELECT
      r2.rateable_type AS rateable_type,
      r2.rateable_id AS rateable_id,
      COUNT(r2.topic_id) AS match_count
    FROM
      ratings r1,
      ratings r2
    WHERE
      r1.rateable_id = %s
    AND
      r1.rateable_type = '%s'
    AND
      r2.rateable_type <> r1.rateable_type
    AND
      r1.topic_id = r2.topic_id
    AND
      r1.score < (r2.score + %s)
    AND
      r1.score > (r2.score - %s)
    GROUP BY
      r2.rateable_type,
      r2.rateable_id
    ORDER BY
      match_count DESC
    LIMIT
      %s
  }

  DEFAULT_SCORE = 1500
  NORMALIZATION_CONSTANT = 400
  POWER_CONSTANT = 10
  UPDATE = 128

  before_validation do
    score
  end

  def topic=(t)
    if !t.nil? && t.kind_of?(String)
      t = Topic.find_or_initialize_by(value: t)
    end
    super(t)
  end

  def score
    orig = super
    if orig.nil?
      orig = DEFAULT_SCORE
      self.score = orig
    end
    orig
  end

  class << self
    def update_elo(user, question, user_correct)
      res = p_user_wins(
        user,
        question.ratings,
      )

      p = res.fetch(:prob)
      q_weight = res.fetch(:question_weight)

      u_weight = 0
      user.ratings.each do |rating|
        rate = rate_score(rating.score)
        u_weight += rate
      end

      user_values = user.ratings.map do |r|
        r.topic.value
      end

      question_values = question.ratings.map do |r|
        r.topic.value
      end

      values = user_values + question_values
      values.uniq!

      Rating.transaction do
        values.each do |topic_value|
          q_rating = question.rating_for(topic_value)
          q_score = q_rating.score
          u_rating = user.rating_for(topic_value)
          u_score = u_rating.score

          u_update = user_update(p, u_score, q_score, q_weight, user_correct)
          logger.info "User: #{user.id}(#{topic_value}) <-- #{u_rating.score} #{u_update}"
          u_rating.update(score: u_rating.score + u_update)

          q_update = question_update(p, u_score, q_score, u_weight, user_correct)
          # logger.info "Question: #{question.id}(#{topic_value}) <-- #{q_rating.score} #{q_update}"
          q_rating.update(score: q_rating.score + q_update)
        end
      end
    end

    def question_update(p, u_score, q_score, weight, user_correct)
      if user_correct
        ((p - 1.0) * UPDATE)
      else
        ((p) * UPDATE)
      end
    end

    def user_update(p, u_score, q_score, weight, user_correct)
      q_rate = rate_score(q_score)
      norm = (q_rate.to_f / weight)
      if user_correct
        ((1.0 - p) * UPDATE) * norm
      else
        ((-p) * UPDATE) * norm
      end
    end

    # probabilty that user gets the question
    # correct
    # returns the probabilty and
    # ratings missing from user
    def p_user_wins(user, question_ratings)
      if question_ratings.empty?
        fail "found: #{question_ratings.inspect} needs to be non-empty to be scored"
      end

      question_weight = 0
      user_probability = 0.0

      count = 0
      question_ratings.each do |rating|
        topic = rating.topic
        if topic.nil?
          fail "found: #{rating.inspect} needs to be non-nil to be scored"
        end

        q_score = rating.score
        q_rate = rate_score(q_score)

        u_rating = user.rating_for(topic.value)
        u_score = u_rating.score

        p = p_single_topic(u_score, q_score)

        user_probability += (q_rate * p)

        question_weight += q_rate
        count += 1
      end
      question_weight = question_weight.to_f / count

      {
        prob: user_probability / question_weight,
        question_weight: question_weight,
      }
    end

    def rate_score(score)
      POWER_CONSTANT ** (score / NORMALIZATION_CONSTANT)
    end

    # probabilty that user gets single topic score
    # correct
    def p_single_topic(user_score, question_score)
      user_r = rate_score(user_score)
      question_r = rate_score(question_score)
      user_r.to_f / (user_r + question_r)
    end
  end
end
