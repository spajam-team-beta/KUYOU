class CreateReplies < ActiveRecord::Migration[7.0]
  def change
    create_table :replies do |t|
      t.references :post, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.text :content, null: false
      t.boolean :is_best, default: false, null: false
      
      t.timestamps
    end
    
    add_index :replies, :is_best
  end
end
