class User < ApplicationRecord
  has_many :products, dependent: :destroy
  has_secure_password

  normalizes :email, :contact_email, with: ->(email) { email.strip.downcase }

  validates :first_name, :location, presence: true, length: { maximum: 80 }
  validates :last_name, length: { maximum: 80 }
  validates :bio, length: { maximum: 1000 }
  validates :email, presence: true, uniqueness: true
  validates :email, :contact_email, format: { with: URI::MailTo::EMAIL_REGEXP },
    length: { maximum: 254 }, allow_blank: true
  validates :password, length: { minimum: 12 }, if: -> { password.present? }
end
