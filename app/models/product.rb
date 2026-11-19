class Product < ApplicationRecord
  CATEGORIES = {
    "regular" => "Classic", "vegan" => "Vegan",
    "glutenfree" => "Gluten-free", "organic" => "Organic"
  }.freeze
  DEMO_PHOTOS = %w[/images/cookies.jpg /images/donuts.jpg /images/macarons.jpg /images/pie.jpg].freeze

  belongs_to :user

  validates :title, presence: true, length: { maximum: 100 }
  validates :description, presence: true, length: { maximum: 1500 }
  validates :category, inclusion: { in: CATEGORIES.keys }
  validate :valid_price
  validates :product_url, length: { maximum: 1000 }
  validate :valid_photo

  def price
    @price || (format("%d.%02d", price_cents / 100, price_cents % 100) if price_cents)
  end

  def price=(value)
    @price = value.to_s.strip
    if @price.match?(/\A\d{1,3}(?:\.\d{1,2})?\z/)
      dollars, cents = @price.split(".")
      self.price_cents = dollars.to_i * 100 + cents.to_s.ljust(2, "0").to_i
    else
      self.price_cents = nil
    end
  end

  private

  def valid_price
    return if price_cents&.between?(1, 99_999)

    errors.add(:price, "must be between $0.01 and $999.99 with up to two decimal places")
  end

  def valid_photo
    return if product_url.blank? || DEMO_PHOTOS.include?(product_url)

    url = URI.parse(product_url)
    return if url.is_a?(URI::HTTPS) && url.host.present? && url.userinfo.nil?

    errors.add(:product_url, "must be a valid HTTPS link")
  rescue URI::InvalidURIError
    errors.add(:product_url, "must be a valid HTTPS link")
  end
end
