class User < ActiveRecord::Base
  include Rateable
  has_many :ratings, as: :rateable

  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, :validatable,
    :confirmable

end
