class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable

  has_many :lesson_users, dependent: :destroy
  has_many :post_users, dependent: :destroy
  has_many :posts, through: :post_users
end
