class AddUnlockCountToPosts < ActiveRecord::Migration[8.0]
  def change
    add_column :posts, :unlock_count, :integer, default: 0
  end
end
