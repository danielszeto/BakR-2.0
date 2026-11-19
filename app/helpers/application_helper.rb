module ApplicationHelper
  def listing_price(product)
    number_to_currency(BigDecimal(product.price_cents) / 100)
  end
end
