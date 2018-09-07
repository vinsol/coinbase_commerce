module CoinbaseCommerce
  class CoinbaseCommerceError < StandardError
    attr_accessor :code, :name
  end
end
