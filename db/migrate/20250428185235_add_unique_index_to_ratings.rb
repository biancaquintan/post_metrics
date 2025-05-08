class AddUniqueIndexToRatings < ActiveRecord::Migration[8.0]
  def change
    add_index :ratings, [ :user_id, :post_id ], unique: true
  end
end
