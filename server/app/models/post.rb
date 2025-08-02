class Post < ApplicationRecord
  # Associations
  belongs_to :user
  has_many :replies, dependent: :destroy
  has_many :sympathies, dependent: :destroy
  
  # Enums
  enum status: { active: 'active', resolved: 'resolved' }
  
  # Validations
  validates :nickname, presence: true, length: { maximum: 50 }
  validates :content, presence: true, length: { maximum: 1000 }
  validates :category, presence: true, inclusion: { in: %w[love work school family friend other] }
  validates :sympathy_count, numericality: { greater_than_or_equal_to: 0 }
  
  # Scopes
  scope :active_posts, -> { where(status: 'active') }
  scope :resolved_posts, -> { where(status: 'resolved') }
  scope :by_category, ->(category) { where(category: category) if category.present? }
  scope :popular, -> { order(sympathy_count: :desc) }
  scope :recent, -> { order(created_at: :desc) }
  
  # Methods
  def resolve_with_best_reply!(reply)
    transaction do
      self.status = 'resolved'
      save!
      
      reply.update!(is_best: true)
    end
  end
  
  def increment_sympathy_count!
    increment!(:sympathy_count)
  end
end