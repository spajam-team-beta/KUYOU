class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: Devise::JWT::RevocationStrategies::Null
  
  # Associations
  has_many :posts, dependent: :destroy
  has_many :replies, dependent: :destroy
  has_many :sympathies, dependent: :destroy
  
  # Validations
  validates :email, presence: true, uniqueness: true
  validates :total_points, numericality: { greater_than_or_equal_to: 0 }
  
  # Methods
  def add_points(amount)
    increment!(:total_points, amount)
  end
end