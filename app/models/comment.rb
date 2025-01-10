class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :post
  belongs_to :lesson, optional: true

  validates :content, presence: true, length: { minimum: 1 }
end
