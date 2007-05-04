require File.dirname(__FILE__) + '/../test_helper'

class RemotePayflowTest < Test::Unit::TestCase
  include ActiveMerchant::Billing

  def setup
    ActiveMerchant::Billing::Base.gateway_mode = :test

    # Your Payflow username and password
    @login = 'LOGIN'
    @password = 'PASSWORD'
    
    # The certification_id is required by PayPal to make direct HTTPS posts to their servers.
    # You can obtain a certification id by emailing: payflowintegrator@paypal.com
    @certification_id = "YOUR_CLIENT_CERTIFICATION"
    
    # Change to the partner you have your account with
    @partner = 'PayPal'
    
    @gateway = PayflowGateway.new(
        :login => @login,
        :password => @password,
        :certification_id => @certification_id,
        :partner => @partner
    )
    
    @creditcard = CreditCard.new(
      :number => '5105105105105100',
      :month => 11,
      :year => 2009,
      :first_name => 'Cody',
      :last_name => 'Fauser',
      :verification_value => '000',
      :type => 'master'
    )

    @options = { :address => { 
                                :name => 'Cody Fauser',
                                :address1 => '1234 Shady Brook Lane',
                                :city => 'Ottawa',
                                :state => 'ON',
                                :country => 'CA',
                                :zip => '90210',
                                :phone => '555-555-5555'
                             },
                 :email => 'cody@example.com'
               }
  end
  
  def test_successful_purchase
    assert response = @gateway.purchase(Money.new(100000), @creditcard, @options)
    assert_equal "Approved", response.message
    assert response.success?
    assert response.test?
    assert_not_nil response.authorization
  end
  
  def test_declined_purchase
    assert response = @gateway.purchase(Money.new(210000), @creditcard, @options)
    assert_equal 'Declined', response.message
    assert !response.success?
    assert response.test?
  end
  
  def test_successful_authorization
    assert response = @gateway.authorize(Money.new(100), @creditcard, @options)
    assert_equal "Approved", response.message
    assert response.success?
    assert response.test?
    assert_not_nil response.authorization
  end

  def test_authorize_and_capture
    amount = Money.new(100)
    assert auth = @gateway.authorize(amount, @creditcard, @options)
    assert auth.success?
    assert_equal 'Approved', auth.message
    assert auth.authorization
    assert capture = @gateway.capture(amount, auth.authorization)
    assert capture.success?
  end
  
  def test_failed_capture
    assert response = @gateway.capture(Money.new(100), '999')
    assert !response.success?
    assert_equal 'Invalid tender', response.message
  end
  
  def test_authorize_and_void
    assert auth = @gateway.authorize(Money.new(100), @creditcard, @options)
    assert auth.success?
    assert_equal 'Approved', auth.message
    assert auth.authorization
    assert void = @gateway.void(auth.authorization)
    assert void.success?
  end
  
  def test_invalid_login
    gateway = PayflowGateway.new(
      :login => '',
      :password => ''
    )
    assert response = gateway.purchase(Money.new(100), @creditcard, @options)
    assert_equal 'Invalid vendor account', response.message
    assert !response.success?
  end
  
  def test_duplicate_request_id
    gateway = PayflowGateway.new(
      :login => @login,
      :password => @password,
      :certification_id => @certification_id,
      :partner => @partner
    )
    
    request_id = Digest::MD5.hexdigest(rand.to_s)
    gateway.expects(:generate_unique_id).times(2).returns(request_id)
    
    response1 = gateway.purchase(Money.new(100), @creditcard, @options)
    assert_nil response1.params['duplicate']
    response2 = gateway.purchase(Money.new(100), @creditcard, @options)
    assert response2.params['duplicate']
  end
  
  def test_create_recurring_profile
    response = @gateway.recurring(1000, @creditcard, :periodicity => :monthly)
    assert response.success?
    assert !response.params['profile_id'].blank?
    assert response.test?
  end
  
  def test_create_recurring_profile_with_invalid_date
    response = @gateway.recurring(1000, @creditcard, :periodicity => :monthly, :starting_at => Time.now)
    assert !response.success?
    assert_equal 'Field format error: Start or next payment date must be a valid future date', response.message
    assert response.params['profile_id'].blank?
    assert response.test?
  end
  
  def test_create_and_cancel_recurring_profile
    response = @gateway.recurring(1000, @creditcard, :periodicity => :monthly)
    assert response.success?
    assert !response.params['profile_id'].blank?
    assert response.test?
    
    response = @gateway.cancel_recurring(response.params['profile_id'])
    assert response.success?
    assert response.test?
  end
  
  def test_full_feature_set_for_recurring_profiles
    # Test add
    @options.update(
      :periodicity => :weekly,
      :payments => '12',
      :starting_at => Time.now + 1.day,
      :comment => "Test Profile"
    )
    response = @gateway.recurring(Money.new(100), @creditcard, @options)
    assert_equal "Approved", response.params['message']
    assert_equal "0", response.params['result']
    assert response.success?
    assert response.test?
    assert !response.params['profile_id'].blank?
    @recurring_profile_id = response.params['profile_id']
  
    # Test modify
    @options.update(
      :periodicity => :monthly,
      :starting_at => Time.now + 1.day,
      :payments => '4',
      :profile_id => @recurring_profile_id
    )
    response = @gateway.recurring(Money.new(400), @creditcard, @options)
    assert_equal "Approved", response.params['message']
    assert_equal "0", response.params['result']
    assert response.success?
    assert response.test?
    
    # Test inquiry
    response = @gateway.recurring_inquiry(@recurring_profile_id) 
    assert_equal "0", response.params['result']
    assert response.success?
    assert response.test?
    
    # Test cancel
    response = @gateway.cancel_recurring(@recurring_profile_id)
    assert_equal "Approved", response.params['message']
    assert_equal "0", response.params['result']
    assert response.success?
    assert response.test?
  end
  
  # Note that this test will only work if you enable reference transactions!!
  def test_reference_purchase
    assert response = @gateway.purchase(Money.new(10000), @creditcard, @options)
    assert_equal "Approved", response.message
    assert response.success?
    assert response.test?
    assert_not_nil pn_ref = response.authorization
    
    # now another purchase, by reference
    assert response = @gateway.purchase(Money.new(10000), pn_ref)
    assert_equal "Approved", response.message
    assert response.success?
    assert response.test?
  end
end
