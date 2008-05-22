require File.dirname(__FILE__) + '/../../test_helper'

class SageTest < Test::Unit::TestCase
  def setup
    @gateway = SageGateway.new(
                 :login => 'login',
                 :password => 'password'
               )

    @credit_card = credit_card
    @amount = 100
    
    @options = { 
      :order_id => '1',
      :billing_address => address,
      :description => 'Store Purchase'
    }
  end
  
  def test_successful_purchase
    @gateway.expects(:ssl_post).returns(successful_purchase_response)
    
    assert response = @gateway.purchase(@amount, @credit_card, @options)
    assert_instance_of Response, response
    assert_success response
    
    assert_equal "APPROVED", response.message
    assert_equal "1234567890", response.authorization

    assert_equal "A",                  response.params["success"]
    assert_equal "911911",             response.params["code"]
    assert_equal "APPROVED",           response.params["message"]
    assert_equal "00",                 response.params["front_end"]
    assert_equal "M",                  response.params["cvv_result"]
    assert_equal "X",                  response.params["avs_result"]
    assert_equal "00",                 response.params["risk"]
    assert_equal "1234567890",         response.params["reference"]
    assert_equal "1000",               response.params["order_number"]
    assert_equal "0",                  response.params["recurring"]
  end

  def test_unsuccessful_purchase
    @gateway.expects(:ssl_post).returns(failed_purchase_response)
    
    assert response = @gateway.purchase(@amount, @credit_card, @options)
    assert_failure response
    assert response.test?
    assert_equal "SECURITY VIOLATION", response.message
    assert_equal "0000000000", response.authorization

    assert_equal "X",                  response.params["success"]
    assert_equal "911911",             response.params["code"]
    assert_equal "SECURITY VIOLATION", response.params["message"]
    assert_equal "00",                 response.params["front_end"]
    assert_equal "P",                  response.params["cvv_result"]
    assert_equal "",                   response.params["avs_result"]
    assert_equal "00",                 response.params["risk"]
    assert_equal "0000000000",         response.params["reference"]
    assert_equal "",                   response.params["order_number"]
    assert_equal "0",                  response.params["recurring"]
  end
  
  def test_avs_result
    @gateway.expects(:ssl_post).returns(successful_purchase_response)

    response = @gateway.purchase(@amount, @credit_card, @options)
    assert_equal 'X', response.avs_result['code']
  end

  def test_cvv_result
    @gateway.expects(:ssl_post).returns(successful_purchase_response)

    response = @gateway.purchase(@amount, @credit_card, @options)
    assert_equal 'M', response.cvv_result['code']
  end

  private
  def successful_purchase_response
    "\002A911911APPROVED                        00MX001234567890\0341000\0340\034\003"
  end
  
  def failed_purchase_response
    "\002X911911SECURITY VIOLATION              00P 000000000000\034\0340\034\003"
  end
end
