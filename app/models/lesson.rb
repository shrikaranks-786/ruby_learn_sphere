class Lesson < ApplicationRecord
  has_one_attached :video
  belongs_to :post
end
