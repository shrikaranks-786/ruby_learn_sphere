class EnsureValidTags < ActiveRecord::Migration[8.0]
  def change
    def up
      Post.where(tag: [nil, '']).update_all(tag: 'uncategorized')
    end
  
    def down
    end
  end
end
