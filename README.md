# CoinbaseCommerce <a href="https://commerce.coinbase.com/docs/api/"><img src="https://commerce.coinbase.com/landing/logo.svg" height="18"></a>

CoinbaseCommerce is an API wrapper for [CoinbaseCommerce's APIs](https://commerce.coinbase.com/docs/api/).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'coinbase_commerce'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install coinbase_commerce

## Usage

You can create an instance of the API wrapper:

    coinbase_commerce = CoinbaseCommerce::API.new("your_api_key")

You can set `api_key`, `timeout`, `throws_exceptions`, `retry_if_fails` and `logger` globally:

    CoinbaseCommerce::API.api_key = "your_api_key"
    CoinbaseCommerce::API.timeout = 15
    CoinbaseCommerce::API.throws_exceptions = false
    CoinbaseCommerce::API.retry_if_fails = true
    CoinbaseCommerce::API.logger = Logger.new("#{Rails.root}/log/coinbase_commerce.log")

You can set webhook `shared_secret` to verify the webhooks.
  CoinbaseCommerce::Webhook.shared_secret = "your_shared_secret"

For example, you could set the values above in an `initializer` file in your `Rails` app (e.g. your\_app/config/initializers/coinbase_commerce.rb).

Assuming you've set an `api_key` on CoinbaseCommerce, you can conveniently make API calls on the class itself:

    CoinbaseCommerce::API.checkouts.all

You can also set the environment variable `COINBASE_COMMERCE_API_KEY` and CoinbaseCommerce will use it when you create an instance:

    coinbase_commerce = CoinbaseCommerce::API.new


### Fetching Checkouts

For example, to fetch all the checkouts of your account:

    checkouts = coinbase_commerce.checkouts.all

### Fetching Charges

Similarly, to fetch your charges:

    lists = coinbase_commerce.charges.all

Or, to fetch a checkout by id:

    checkout = coinbase_commerce.checkouts.find('checkout_id')

Or, to delete a checkout by id:

    checkout = coinbase_commerce.checkouts.delete('checkout_id')


Or, to update a checkout by id:

    checkout = coinbase_commerce.checkouts.update(id: 'checkout_id', name: 'Updated name')

    passing id to update any resource is necessory

The above examples were for only checkout resource. Same way it can be used for other resources i.e. charges, events etc.

To verify a webhook request you can simply check in a `before_action`

    begin
      CoinbaseCommerce::Webhook.verify(request)
    rescue CoinbaseCommerce::CoinbaseCommerceError => e
      # do something 
    end


### Setting timeouts

CoinbaseCommerce defaults to a 30 second timeout. You can optionally set your own timeout (in seconds) like so:

    coinbase_commerce = CoinbaseCommerce::API.new("your_api_key", {:timeout => 5})

or

    coinbase_commerce.timeout = 5

### Error handling

By default CoinbaseCommerce will attempt to raise errors returned by the API automatically.

If you set the `throws_exceptions` boolean attribute to false, for a given instance,
then CoinbaseCommerce will not raise exceptions. This allows you to handle errors manually. The
APIs will return a Hash with "error".

If you rescue CoinbaseCommerce::CoinbaseCommerceError, you are provided with the error message itself as well as
a `code` attribute that you can map onto the API's error list. The API docs list possible errors
at the bottom of each page. Here's how you might do that:

    begin
      coinbase_commerce.checkouts.all
    rescue CoinbaseCommerce::CoinbaseCommerceError => e
      # do something with e.message here
      # do something wiht e.code here
    end

## Contributing

1. Fork it ( https://github.com/[my-github-username]/coinbase_commerce/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
