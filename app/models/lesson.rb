class Lesson < ApplicationRecord
  has_one_attached :video
  belongs_to :post
  has_many :lessons_users, dependent: :destroy
end
