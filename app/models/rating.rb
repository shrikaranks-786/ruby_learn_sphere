class Rating < ApplicationRecord
  belongs_to :post
  belongs_to :user
  
  validates :score, presence: true, inclusion: { in: 1..5 }
  validates :post_id, uniqueness: { scope: :user_id, message: "You've already rated this course" }
end
