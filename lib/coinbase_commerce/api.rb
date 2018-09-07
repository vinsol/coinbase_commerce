module CoinbaseCommerce
  class API

    API_RESOURCES = %w{charges checkouts events}
    attr_accessor :api_key, :api_endpoint, :timeout, :throws_exceptions, :version

    def initialize(api_key=nil, default_parameters={})
      @api_key = api_key || self.class.api_key || ENV['COINBASE_COMMERCE_API_KEY']
      @api_key = @api_key.strip if @api_key

      @api_endpoint = default_parameters.delete(:api_endpoint) || self.class.api_endpoint
      @version = default_parameters.delete(:version)
      @timeout = default_parameters.delete(:timeout) || self.class.timeout
      @throws_exceptions = default_parameters.has_key?(:throws_exceptions) ? default_parameters.delete(:throws_exceptions) : self.class.throws_exceptions

      @default_params = default_parameters
    end

    def method_missing(method, *args)
      if API_RESOURCES.include?(method.to_s)
        api = APICategory.new(method.to_s, @api_key, @timeout, @throws_exceptions, @api_endpoint, @version, @default_params)
        api.api_endpoint = @api_endpoint if @api_endpoint
        api
      else
        super
      end
    end

    class << self
      attr_accessor :api_key, :timeout, :throws_exceptions, :api_endpoint, :retry_if_fails, :max_try_count, :logger, :version

      def logger
        @logger || CoinbaseCommerce::APILogger.new
      end

      def method_missing(sym, *args, &block)
        if API_RESOURCES.include?(sym.to_s)
          new(self.api_key, {api_endpoint: self.api_endpoint, timeout: self.timeout, throws_exceptions: self.throws_exceptions, version: self.version}).send(sym, *args, &block)
        else
          super
        end
      end
    end
  end
end
