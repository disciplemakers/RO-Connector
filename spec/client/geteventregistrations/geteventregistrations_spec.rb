require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "GetEventRegistrations" do
  describe "without credentials" do
    it "shouldn't instantiate" do
      lambda { roc_get_event_registrations = RegonlineConnector::Client::GetEventRegistrations.new }.should raise_exception(ArgumentError)
    end
  end
  
  describe "with any credentials" do
    before(:each) do
      mock_WSDLDriverFactory = mock('WSDLDriverFactory')
      mock_RPCDriver = mock('Driver')
      mock_WSDLDriverFactory.should_receive(:create_rpc_driver).and_return(mock_RPCDriver)
      SOAP::WSDLDriverFactory.should_receive(:new).with('http://www.regonline.com/webservices/getEventRegistrations.asmx?WSDL').and_return(mock_WSDLDriverFactory)
      @roc_ger = RegonlineConnector::Client::GetEventRegistrations.new(100, 'joeuser', 'password')
    end
    
    it "should not give read access to event_id" do
      lambda { @roc_ger.event_id }.should raise_exception(NoMethodError)
    end
    
    it "should not give read access to username" do
      lambda { @roc_ger.username }.should raise_exception(NoMethodError)
    end
    
    it "should not give read access to password" do
      lambda { @roc_ger.password }.should raise_exception(NoMethodError)
    end
    
    it "should not give write access to event_id" do
      lambda { @roc_ger.event_id=200 }.should raise_exception(NoMethodError)
    end
    
    it "should not give write access to username" do
      lambda { @roc_ger.username='joeuser' }.should raise_exception(NoMethodError)
    end
    
    it "should not give write access to password" do
      lambda { @roc_ger.password='password' }.should raise_exception(NoMethodError)
    end
  end
  
  describe "with valid credentials" do
    before(:each) do
      @xml = "<registrations>" +
             "<registration id=\"12345678\" firstName=\"John\" lastName=\"Doe\" />" +
             "<registration id=\"87654321\" firstName=\"Jane\" lastName=\"Smith\" />" +
             "</registrations>"
      mock_WSDLDriverFactory = mock('SOAPWSDLDriverFactory')
      mock_RPCDriver = mock('SOAPRPCDriver')
      mock_MappingObject = mock('SOAPMappingObject')
      mock_MappingObject.stub(:retrieveRegistrationInfoResult).and_return(@xml)
      mock_RPCDriver.stub(:RetrieveRegistrationInfo).with(
                                    {"login"          => 'joeuser',
                                     "password"       => 'password',
                                     "eventID"        => 1000}
                                     ).and_return(mock_MappingObject)
      mock_WSDLDriverFactory.should_receive(:create_rpc_driver).and_return(mock_RPCDriver)
      SOAP::WSDLDriverFactory.should_receive(:new).with(
              'http://www.regonline.com/webservices/getEventRegistrations.asmx?WSDL'
              ).and_return(mock_WSDLDriverFactory)
      @roc_ger = RegonlineConnector::Client::GetEventRegistrations.new(1000, 'joeuser', 'password')
    end
    
    it "should return XML when RetrieveRegistrationInfo is called" do
      @roc_ger.RetrieveRegistrationInfo.should == @xml
    end
  end
  
  describe "with invalid credentials" do
    before(:each) do
      mock_WSDLDriverFactory = mock('SOAPWSDLDriverFactory')
      mock_RPCDriver = mock('SOAPRPCDriver')
      mock_RPCDriver.stub(:RetrieveRegistrationInfo).with(
                                    {"login"          => 'joeuser',
                                     "password"       => 'bad_password',
                                     "eventID"        => 1000}
                                     ).and_raise(SOAP::FaultError.new(
                                          SOAP::SOAPFault.new(SOAP::SOAPString.new('Server'),
                                                              SOAP::SOAPString.new('Authentication failure'))))
      mock_RPCDriver.stub(:RetrieveRegistrationInfo).with(
                              {"login"          => 'joeuser',
                               "password"       => 'password',
                               "eventID"        => 9999}
                               ).and_raise(SOAP::FaultError.new(
                                    SOAP::SOAPFault.new(SOAP::SOAPString.new('Server'),
                                                        SOAP::SOAPString.new('Object reference not set to an instance of an object.'))))
      mock_WSDLDriverFactory.should_receive(:create_rpc_driver).and_return(mock_RPCDriver)
      SOAP::WSDLDriverFactory.should_receive(:new).with(
              'http://www.regonline.com/webservices/getEventRegistrations.asmx?WSDL'
              ).and_return(mock_WSDLDriverFactory)
    end
    
    it "should raise a SOAP fault error with bad password" do 
      roc_ger = RegonlineConnector::Client::GetEventRegistrations.new(1000, 'joeuser', 'bad_password')
      lambda { roc_ger.RetrieveRegistrationInfo }.should raise_exception(SOAP::FaultError)
    end
    
    it "should raise a SOAP fault error with any bad event id" do
      roc_ger = RegonlineConnector::Client::GetEventRegistrations.new(9999, 'joeuser', 'password') 
      lambda { roc_ger.RetrieveRegistrationInfo }.should raise_exception(SOAP::FaultError)
    end
  end
  
end