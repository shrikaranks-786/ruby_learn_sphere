class RemovePostIdFromChatbots < ActiveRecord::Migration[8.0]
  def change
    remove_column :chatbots, :post_id, :integer
  end
end
