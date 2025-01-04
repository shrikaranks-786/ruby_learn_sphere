class Chatbot < ApplicationRecord
  # Remove this line if you don't need the association
  # belongs_to :post
  validates :question, presence: true
  validates :answer, presence: true
end
