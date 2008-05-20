module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    # Bogus Gateway
    class BogusExpressGateway < Gateway
      AUTHORIZATION = '53433'
      LIVE_REDIRECT_URL = 'https://www.paypal.com/cgibin/webscr?cmd=_express-checkout&token='
      TEST_REDIRECT_URL = 'https://www.sandbox.paypal.com/cgi-bin/webscr?cmd=_express-checkout&token='

      
      SUCCESS_MESSAGE = "Bogus Express Gateway: Forced success"
      FAILURE_MESSAGE = "Bogus Express Gateway: Forced failure"
      ERROR_MESSAGE = "Bogus Express Gateway: Use CreditCard number 1 for success, 2 for exception and anything else for error"
      CREDIT_ERROR_MESSAGE = "Bogus Express Gateway: Use trans_id 1 for success, 2 for exception and anything else for error"
      UNSTORE_ERROR_MESSAGE = "Bogus Express Gateway: Use trans_id 1 for success, 2 for exception and anything else for error"
      CAPTURE_ERROR_MESSAGE = "Bogus Express Gateway: Use authorization number 1 for exception, 2 for error and anything else for success"
      
      self.supported_countries = ['US']
      self.supported_cardtypes = [:bogus]
      self.homepage_url = 'http://example.com'
      self.display_name = 'Bogus Express'

      def redirect_url
        test? ? TEST_REDIRECT_URL : LIVE_REDIRECT_URL 
      end
      
      def redirect_url_for(token)
        "#{redirect_url}#{token}"
      end

      def setup_authorization(money, options={})
        requires!(options, :return_url, :cancel_return_url)
        PaypalExpressResponse.new(
          true, 
          SUCCESS_MESSAGE,
          self.response_hash(options),
          { :test => true, }.update(options)
        )
      end

      def setup_purchase(money, options = {})
        requires!(options, :return_url, :cancel_return_url)
        PaypalExpressResponse.new(
          true, 
          SUCCESS_MESSAGE,
          response_hash(options),
          { :test => true, }.update(options)
        )
      end

      def details_for(token)
        PaypalExpressResponse.new(
          true, 
          SUCCESS_MESSAGE,
          response_hash(options),
          { :test => true, }.update(options)
        )
      end


      def authorize(money, options = {})
        requires!(options, :token, :payer_id)
        PaypalExpressResponse.new(
          true, 
          SUCCESS_MESSAGE,
          response_hash(options),
          { :test => true, }.update(options)
        )
      end

      def purchase(money, options = {})
        requires!(options, :token, :payer_id)
        PaypalExpressResponse.new(
          true, 
          SUCCESS_MESSAGE,
          response_hash(options),
          { :test => true, }.update(options)
        )
      end

      def capture(money, authorization, options = {})
        requires!(options, :token, :payer_id)
        PaypalExpressResponse.new(
          true, 
          SUCCESS_MESSAGE,
          response_hash(options),
          { :test => true, }.update(options)
        )
      end
      def response_hash(options = {})
        {
          :payer => "john@doe.com", 
          :token => "EC-11235829203",
          :first_name => "John",
          :middle_name => "Q.",
          :last_name => "Doe",
          :payer_id => "123",
          :payer_business => "John's Diner",
          :street1 => "123 Main Street",
          :street2 => "#100",
          :city_name => "Test City",
          :state_or_province => "Arizona",
          :country => "US",
          :postal_code => "85260",
        }.update(options) 
      end
    end
  end
end
