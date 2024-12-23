class AddMoreColsToPost < ActiveRecord::Migration[8.0]
  def change
    add_column :posts, :paid, :boolean
    add_column :posts, :stripe_price_id, :string
    add_column :posts, :premium_description, :text
  end
end
