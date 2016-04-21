module Rateable
  extend ActiveSupport::Concern

  included do
    has_many :topics, through: :ratings
  end

  def top_ratings(top_n = 20)
    ratings.order(score: :desc).limit(top_n)
  end

  def top_ratings_and_percent(top_n = 20)
    top = top_ratings(top_n)

    Rating.transaction do
      total_count = self.class.count

      top.map do |r|
        count = Rating.where(
          'score > ? AND rateable_type = ? AND topic_id = ?',
          r.score,
          self.class.name,
          r.topic_id,
        ).count

        percentile = 100.0 - (100.0 * count.to_f / total_count)

        {
          rating: r,
          percentile: percentile,
        }
      end
    end
  end

  def orig_rating_list
    @orig_ratings_list ||= ratings
  end

  def iter_idx
    @iter_idx ||= 0
  end

  def reset_ratings_cache
    @orig_ratings_list = nil
    @iter_idx = nil
  end

  def pretty_ratings
    ratings.map do |rating|
      {
        score: rating.score,
        topic: rating.topic.value,
      }
    end
  end

  def ratings_cache(reset = false)
    if reset
      reset_ratings_cache
    end

    @ratings_cache ||= Hash.new do |h, topic_value|
      rating = nil
      while (iter_idx < orig_rating_list.size) do
        r = orig_rating_list[iter_idx]
        @iter_idx += 1

        h[r.topic.value] = r

        if topic_value == r.topic.value
          rating = r
          break
        end
      end

      if rating.nil?
        rating = Rating.new(topic: topic_value, rateable: self)
        h[topic_value] = rating
        self.ratings << rating
      end

      rating
    end
  end

  def rating_for(topic_value)
    ratings_cache[topic_value]
  end
end
