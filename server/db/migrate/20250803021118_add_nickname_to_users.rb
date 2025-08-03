class AddNicknameToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :nickname, :string, limit: 30
    add_index :users, :nickname
  end
end
