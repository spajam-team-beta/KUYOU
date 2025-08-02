class CreatePosts < ActiveRecord::Migration[7.0]
  def change
    create_table :posts do |t|
      t.references :user, null: false, foreign_key: true
      t.string :nickname, null: false, limit: 50
      t.text :content, null: false
      t.string :category, null: false, limit: 20
      t.string :status, default: 'active', null: false
      t.integer :sympathy_count, default: 0, null: false
      
      t.timestamps
    end
    
    add_index :posts, [:status, :created_at]
  end
end
