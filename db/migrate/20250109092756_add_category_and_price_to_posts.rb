class AddCategoryAndPriceToPosts < ActiveRecord::Migration[8.0]
  def change
    add_column :posts, :category, :string
    add_column :posts, :price, :decimal
  end
end
