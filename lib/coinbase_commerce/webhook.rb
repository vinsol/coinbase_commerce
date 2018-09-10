module CoinbaseCommerce
  class Webhhok
    cattr_accessor :shared_secret

    def self.verify(request)
      payload = request.body.read
      signature = request.headers['X-CC-Webhook-Signature']
      token = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new("sha256"), shared_secret, payload)
      unless ActiveSupport::SecurityUtils.secure_compare(token, signature)
        raise CoinbaseCommerce::CoinbaseCommerceError.new("Signature not matching the payload")
      end
    end
  end
end
