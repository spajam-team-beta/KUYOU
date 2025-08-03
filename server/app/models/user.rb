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
  validates :nickname, length: { maximum: 30 }, uniqueness: { allow_blank: true }
  
  # Methods
  def add_points(amount)
    increment!(:total_points, amount)
  end
  
  def display_nickname
    nickname.present? ? nickname : "智者##{id.to_s.rjust(4, '0')}"
  end
end