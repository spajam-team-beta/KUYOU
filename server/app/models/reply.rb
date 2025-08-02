class Reply < ApplicationRecord
  # Associations
  belongs_to :post
  belongs_to :user
  
  # Validations
  validates :content, presence: true, length: { maximum: 500 }
  
  # Scopes
  scope :best_replies, -> { where(is_best: true) }
  scope :recent, -> { order(created_at: :desc) }
  
  # Callbacks
  before_create :ensure_post_is_active
  
  private
  
  def ensure_post_is_active
    errors.add(:post, "はすでに成仏済みです") if post.resolved?
  end
end