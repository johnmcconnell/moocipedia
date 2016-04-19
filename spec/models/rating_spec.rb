require 'rails_helper'

RSpec.describe Rating, type: :model do
  let(:user) do
    User.new(ratings: user_ratings)
  end

  let(:user_ratings) do
    [
      Rating.new(topic: 'A', score: 1500),
      Rating.new(topic: 'B', score: 100),
      Rating.new(topic: 'C', score: 100),
    ]
  end

  let(:question_ratings) do
    [
      Rating.new(topic: 'A', score: 1400),
      Rating.new(topic: 'C', score: 400),
      Rating.new(topic: 'D', score: 1500),
    ]
  end

  let(:missed_ratings) do
    {
      'D' => Rating.new(topic: 'D', score: 1500),
    }
  end

  let(:user_t1) do
    User.new(ratings: user_ratings_t1)
  end

  let(:user_ratings_t1) do
    [
      Rating.new(topic: 'A', score: 1500),
      Rating.new(topic: 'B', score: 100),
      Rating.new(topic: 'C', score: 100),
    ]
  end

  let(:question_ratings_t1) do
    [
      Rating.new(topic: 'A', score: 1400),
      Rating.new(topic: 'C', score: 100),
      Rating.new(topic: 'D', score: 1500),
    ]
  end

  let(:user_t2) do
    User.new(ratings: user_ratings_t2)
  end

  let(:user_ratings_t2) do
    [
      Rating.new(topic: 'A', score: 2700),
      Rating.new(topic: 'B', score: 2700),
      Rating.new(topic: 'C', score: 4000),
    ]
  end

  let(:question_ratings_t2) do
    [
      Rating.new(topic: 'A', score: 3000),
      Rating.new(topic: 'B', score: 3000),
      Rating.new(topic: 'C', score: 500),
    ]
  end

  describe '#p_user_wins' do
    it 'calculates the percentage the user wins' do
      res = Rating.p_user_wins(
        user,
        question_ratings,
      )

      p = res.fetch(:prob)
      q_weight = res.fetch(:question_weight)
      expected_q_weight = [
        1400,
        400,
        1500,
      ].reduce(0) do |a, e|
        a + Rating.rate_score(e)
      end

      # expect(q_weight).to eq(expected_q_weight)

      # expect(p).to be_within(0.5).of(0.5)
      # expect(p).to be_within(0.01).of(0.5)
    end

    it 'p trial 1' do
      res = Rating.p_user_wins(
        user_t1,
        question_ratings_t1,
      )
      p = res.fetch(:prob)

      # expect(p).to be_within(0.5).of(0.5)
      # expect(p).to be_within(0.01).of(0.5)
    end

    it 'p trial 2' do
      res = Rating.p_user_wins(
        user_t2,
        question_ratings_t2,
      )
      p = res.fetch(:prob)

      # expect(p).to be_within(0.5).of(0.5)
      # expect(p).to be_within(0.01).of(0.09)
    end
  end
end
