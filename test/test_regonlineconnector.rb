require 'helper'

class TestRegonlineconnector < Test::Unit::TestCase
  def test_testing_system
    assert true
  end
  
  def test_instantiation_requires_account_info
    assert_raise ArgumentError do
      roc = RegonlineConnector.new  
    end
  end
  
  def test_no_accessors_for_account_info
    roc = RegonlineConnector.new(100, 'joeuser', 'password')
    
    msg = 'RegonlineConnector allowed access to account_id'
    assert_raise NoMethodError, msg do
      account_id = roc.account_id
    end
    
    msg = 'RegonlineConnector allowed access to username'
    assert_raise NoMethodError, msg do
      username = roc.username
    end
    
    msg = 'RegonlineConnector allowed access to password'
    assert_raise NoMethodError, msg do
      password = roc.password
    end
  end
  
  def test_bogus_authentication_should_return_false
    roc = RegonlineConnector.new(100, 'joeuser', 'password')
    msg = 'Authentication attempt using sample data did not return false.'
    assert_instance_of FalseClass, roc.authenticate, msg
  end
  
  def test_get_events__hash
    
  end
end
