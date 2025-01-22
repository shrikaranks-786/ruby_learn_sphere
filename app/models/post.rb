class Post < ApplicationRecord
  has_one_attached :image do |attachable|
    attachable.variant :thumb, resize_to_limit: [100, 100]
  end
  has_many :lessons, dependent: :destroy
  has_many :post_users
  has_and_belongs_to_many :categories
  has_many :users, through: :post_users
  has_many :comments, dependent: :destroy
  has_many :ratings, dependent: :destroy
  
  has_rich_text :description
  has_rich_text :premium_description
  
  validates :tag, presence: true
  validates :tag, format: { with: /\A[a-zA-Z0-9\s,]+\z/, 
                          message: "only allows letters, numbers, spaces, and commas" }
  before_validation :normalize_tag
  
  def normalize_tag
    self.tag = tag.strip.downcase if tag.present?
  end
  
  def first_lesson
    self.lessons.order(:position).first
  end
  
  def next_lesson(current_user)
    if current_user.blank?
      return self.lessons.order(:position).first
    end
    
    completed_lessons = current_user.lesson_users.includes(:lesson).where(completed: true).where(lessons: { post_id: self.id })
    started_lessons = current_user.lesson_users.includes(:lesson).where(completed: false).where(lesson: { post_id: self.id }).order(:position)
    
    if started_lessons.any?
      return started_lessons.first.lesson
    end
    
    lessons = self.lessons.where.not(id: completed_lessons.pluck(:lesson_id)).order(:position)
    if lessons.any?
      lessons.first
    else
      self.lessons.order(:position).first
    end
  end
  
  def average_rating
    ratings.average(:score)&.round(2) || 0
  end
  
  def increment_unlock_count!
    increment!(:unlock_count)
  end
  
  def self.trending_by_tags(limit = 3)
    valid_posts = where.not(tag: [nil, ''])
    
    return [] if valid_posts.empty?
   
    tag_counts = valid_posts.group(:tag).count

    tag_scores = {}
    tag_counts.each do |tag, count|
     
      base_score = count
      
      
      total_unlocks = valid_posts.where(tag: tag).sum(:unlock_count)
      
      recent_posts_count = valid_posts.where(tag: tag)
                                    .where('created_at > ?', 30.days.ago)
                                    .count

      tag_scores[tag] = (base_score * 2) + 
                       (total_unlocks * 1.5) + 
                       (recent_posts_count * 3)
    end
    
    # Sort tags by score and get posts
    trending_posts = []
    tag_scores.sort_by { |_, score| -score }.each do |tag, _|
      # Get top posts for this tag, ordered by unlock count and creation date
      tag_posts = valid_posts.where(tag: tag)
                            .order(unlock_count: :desc, created_at: :desc)
                            .limit(2)  # Get top 2 posts per tag to ensure variety
      
      trending_posts.concat(tag_posts)
    end
    
    # Return unique trending posts, limited to requested amount
    trending_posts.uniq.take(limit)
  end
end