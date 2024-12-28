class AddPaidForCourseToPosts < ActiveRecord::Migration[8.0]
  def change
    add_column :posts, :paid_for_course, :boolean
  end
end
