require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "RegonlineConnector" do
  
  it "shouldn't instantiate without account info" do
    lambda { roc = RegonlineConnector.new }.should raise_exception(ArgumentError)
  end
  
  describe "with valid credentials" do
    before(:each) do
      @roc = RegonlineConnector.new(100, 'joeuser', 'password')
    end
    
    it "should not give access to account_id" do
      lambda { @roc.account_id }.should raise_exception(NoMethodError)
    end
    
    it "should not give access to username" do
      lambda { @roc.username }.should raise_exception(NoMethodError)
    end
    
    it "should not give access to password" do
      lambda { @roc.password }.should raise_exception(NoMethodError)
    end
    
    it "should successfully authenticate" do
      mock_client = mock('roc_client')
      mock_client.should_receive(:authenticate).and_return(true)
      RegonlineConnector::Client.should_receive(:new).with(100, 'joeuser', 'password').and_return(mock_client)
      mock_roc = RegonlineConnector.new(100, 'joeuser', 'password')
      mock_roc.authenticate.should == true
    end
  end
end
