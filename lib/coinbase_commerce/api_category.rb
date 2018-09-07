require 'coinbase_commerce/api'
require 'uri'

module CoinbaseCommerce
  class APICategory
    include HTTParty
    format :plain
    default_timeout 30

    attr_accessor :category_name, :api_key, :api_endpoint, :timeout, :throws_exceptions, :default_params, :version

    def initialize(category_name, api_key, timeout, throws_exceptions, api_endpoint, version, default_params)
      @category_name = category_name
      @api_key = api_key
      @api_endpoint = api_endpoint || get_api_endpoint
      @default_params = default_params
      @throws_exceptions = throws_exceptions
      @timeout = timeout
      @try_count = 0
      @version = version || get_api_version

      set_instance_defaults
    end

    def call(method, params = {})
      ensure_api_key
      set_api_url
      params = @default_params.merge(params)
      if (response = send_api_request(method, params))
        parsed_response = RecursiveOpenStruct.new(response.parsed_response, preserve_original_keys: true, recurse_over_arrays: true)
        raise_error_with_message(parsed_response) if should_raise_for_response?(response.code)
        parsed_response.data
      end
    end

    def send_api_request(method, params)
      begin
        CoinbaseCommerce::API.logger.info "Try Count: #{ @try_count } Start CoinbaseCommerce API Request #{ @api_url }"
        response = HTTParty.send(method, @api_url, :body => MultiJson.dump(params), headers: { 'X-CC-Api-Key' => @api_key, 'X-CC-Version' => @version }, :timeout => @timeout)
        CoinbaseCommerce::API.logger.info "Try Count: #{ @try_count } End CoinbaseCommerce API Request Response Code: #{response.code}"
        raise CoinbaseCommerceError, 'Retrying TooManyRequestsError Response Code: 429' if (response.code == 429 && should_retry_if_fails?)
        return response
      rescue StandardError => e
        CoinbaseCommerce::API.logger.error "ERROR:#{e} #{e.message}"
        if should_retry_if_fails?
          @try_count += 1
          call(method, params)
        else
          raise e
        end
      end
      return nil
    end

    def set_api_url
      @api_url = URI.encode("#{@api_endpoint}/#{@category_name}")
    end

    def raise_error_with_message(parsed_response)
      parsed_error = parsed_response.error || OpenStruct.new
      error = CoinbaseCommerceError.new(parsed_error.message)
      error.code = parsed_error.error
      error.name = parsed_error.code
      CoinbaseCommerce::API.logger.error "ERROR:#{error.name} #{error.message} ERROR CODE: #{error.code}"
      raise error
    end

    def find(id)
      self.category_name = "#{category_name}/#{id}"
      call(:get)
    end

    def all
      call(:get)
    end

    def create(args={})
      call(:post, args)
    end

    def delete(id)
      self.category_name = "#{category_name}/#{id}"
      call(:delete)
    end

    def update(args={})
      if id = args.delete(:id)
        self.category_name = "#{category_name}/#{id}"
        call(:put, args)
      else
        CoinbaseCommerce::API.logger.error "ERROR: Please give id of #{@category_name} for update"
        raise CoinbaseCommerceError, "Please give id of #{@category_name} for update"
      end
    end

    def set_instance_defaults
      @timeout = (API.timeout || 30) if @timeout.nil?
      @throws_exceptions = API.throws_exceptions if @throws_exceptions.nil?
      @throws_exceptions = true if @throws_exceptions.nil?
    end

    def api_key=(value)
      @api_key = value.strip if value
    end

    def should_raise_for_response?(response_code)
      @throws_exceptions && (400..500).include?(response_code)
    end

    def should_retry_if_fails?
      CoinbaseCommerce::API.retry_if_fails && (@try_count < (CoinbaseCommerce::API.max_try_count || 5))
    end

    def get_api_endpoint
      'https://api.commerce.coinbase.com'
    end

    def get_api_version
      '2018-03-22'
    end

    private

    def ensure_api_key
      unless @api_key
        CoinbaseCommerce::API.logger.error 'ERROR: You must set an api_key prior to making a call'
        raise CoinbaseCommerce::CoinbaseCommerceError, 'You must set an api_key prior to making a call'
      end
    end
  end
end
