class CreateChatbots < ActiveRecord::Migration[8.0]
  def change
    create_table :chatbots do |t|
      t.text :question
      t.text :answer
      t.references :post, null: false, foreign_key: true

      t.timestamps
    end
  end
end
