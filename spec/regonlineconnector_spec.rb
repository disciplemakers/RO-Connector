require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "RegonlineConnector" do
  
  it "shouldn't instantiate without account info" do
    lambda { roc = RegonlineConnector.new }.should raise_exception(ArgumentError)
  end
  
  it "should not give access to account_id" do
    roc = RegonlineConnector.new(100, 'joeuser', 'password')
    lambda { roc.account_id }.should raise_exception(NoMethodError)
  end
  
  it "should not give access to username" do
    roc = RegonlineConnector.new(100, 'joeuser', 'password')
    lambda { roc.username }.should raise_exception(NoMethodError)
  end
  
  it "should not give access to password" do
    roc = RegonlineConnector.new(100, 'joeuser', 'password')
    lambda { roc.password }.should raise_exception(NoMethodError)
  end
  
  it "should not authenticate with bogus credentials" do
    roc = RegonlineConnector.new(100, 'joeuser', 'password')
    roc.authenticate.should be_an_instance_of(FalseClass)
  end
end
