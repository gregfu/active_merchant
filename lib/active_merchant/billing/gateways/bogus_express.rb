module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    class BogusExpressResponse < Response
      def email
        "greg_fu@example.com"
      end
      
      def name
        "Greg Fu"
      end
      
      def token
        "1234567890"
      end
      
      def payer_id
        "123"
      end
      
      def payer_country
        "US"
      end
      
      def address
        {  'name'       => "Greg", 
           'company'    => "Fu",
           'address1'   => "123 Test St",
           'address2'   => "",
           'city'       => "Test City",
           'state'      => "AZ",
           'country'    => "US",
           'zip'        => 85001,
           'phone'      => nil
        }
      end
    end

    # Bogus Gateway
    class BogusExpressGateway < Gateway
      AUTHORIZATION = '53433'


      LIVE_REDIRECT_URL = 'https://www.paypal.com/cgibin/webscr?cmd=_express-checkout&token='
      TEST_REDIRECT_URL = 'https://www.sandbox.paypal.com/cgi-bin/webscr?cmd=_express-checkout&token='

      CONFIRM_TOKEN = "CONFIRM"
      CANCEL_TOKEN  = "CANCEL"

      
      SUCCESS_MESSAGE = "Bogus Express Gateway Success"
      FAILURE_MESSAGE = "Bogus Express Gateway: Forced failure"
      ERROR_MESSAGE = "Bogus Express Gateway: Error message"

      CREDIT_ERROR_MESSAGE = "Bogus Express Gateway: Use trans_id 1 for success, 2 for exception and anything else for error"
      UNSTORE_ERROR_MESSAGE = "Bogus Express Gateway: Use trans_id 1 for success, 2 for exception and anything else for error"
      CAPTURE_ERROR_MESSAGE = "Bogus Express Gateway: Use authorization number 1 for exception, 2 for error and anything else for success"
      
      self.supported_countries = ['US']
      self.supported_cardtypes = [:bogus]
      self.homepage_url = 'http://example.com'
      self.display_name = 'Bogus Express'

      def redirect_url

      end
      
      def redirect_url_for(token, options = {})
        unless options[:cancel]
          ENV["success_url"] % [token, 1]
        else
          ENV["cancel_url"] % [token, 1]
        end
      end

      def setup_authorization(money, options={})
        requires!(options, :return_url, :cancel_return_url)
        if money != 14000
          BogusExpressResponse.new(
            true, 
            SUCCESS_MESSAGE,
            self.response_hash(options),
            { :test => true, }.update(options)
          )
        else
          BogusExpressResponse.new(
            false, 
            FAILURE_MESSAGE,
            self.response_hash(options),
            { :test => true, }.update(options)
          )
        end
      end

      def setup_purchase(money, options = {})
        requires!(options, :return_url, :cancel_return_url)
        BogusExpressResponse.new(
          true, 
          SUCCESS_MESSAGE,
          response_hash(options),
          { :test => true, }.update(options)
        )
      end

      def details_for(token)
        BogusExpressResponse.new(
          true, 
          SUCCESS_MESSAGE,
          response_hash,
          { :test => true, }
        )
      end


      def authorize(money, options = {})
        requires!(options, :token, :payer_id)
        BogusExpressResponse.new(
          true, 
          SUCCESS_MESSAGE,
          response_hash(options),
          { :test => true, }.update(options)
        )
      end

      def purchase(money, options = {})
        requires!(options, :token, :payer_id)
        BogusExpressResponse.new(
          true, 
          SUCCESS_MESSAGE,
          response_hash(options),
          { :test => true, }.update(options)
        )
      end

      def capture(money, authorization, options = {})
        requires!(options, :token, :payer_id)
        BogusExpressResponse.new(
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
