class Sympathy < ApplicationRecord
  # Associations
  belongs_to :post
  belongs_to :user
  
  # Validations
  validates :user_id, uniqueness: { scope: :post_id, message: "はすでにこの投稿に供養済みです" }
  
  # Callbacks
  after_create :increment_post_sympathy_count
  after_destroy :decrement_post_sympathy_count
  
  private
  
  def increment_post_sympathy_count
    post.increment_sympathy_count!
  end
  
  def decrement_post_sympathy_count
    post.decrement!(:sympathy_count)
  end
end