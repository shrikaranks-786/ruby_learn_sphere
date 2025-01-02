class AdminController < ApplicationController
    layout "admin" # Ensure this points to the correct layout file
    before_action :authenticate_admin!
    def index
        @quick_stats = {
            sign_ups: User.where("created_at > ?", 1.week.ago).count,
            sales: PostUser.where("created_at > ?", 1.week.ago).count,
            completed_lessons: LessonUser.where("created_at > ?",1.week.ago).where(completed:true).count,
            total_sign_ups: User.count
        }
        @completed_lessons_by_day = LessonUser.where("created_at > ?", 1.week.ago).where(completed: true).group_by_day(:created_at, format: "%A").count
        @sign_ups_by_day = User.where("created_at > ?", 1.week.ago).group_by_day(:created_at, format: "%A").count
    end
end